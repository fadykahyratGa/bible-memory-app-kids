create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[0-9]{4}$'),
  host_user_id uuid not null references auth.users(id) on delete restrict,
  mode text not null default 'individual' check (mode in ('individual', 'teams')),
  status text not null default 'lobby' check (status in ('lobby', 'team_selection', 'wheel', 'playing', 'round_result', 'finished', 'closed')),
  timer_seconds integer not null default 45 check (timer_seconds in (30, 45, 60, 90)),
  skip_penalty_seconds integer not null default 3 check (skip_penalty_seconds in (0, 3, 5)),
  rounds_to_win integer not null default 3 check (rounds_to_win in (1, 2, 3, 5)),
  difficulty text not null default 'mixed' check (difficulty in ('easy', 'medium', 'hard', 'mixed')),
  testament text not null default 'both' check (testament in ('old', 'new', 'both')),
  show_question_to_opponents boolean not null default true,
  max_players integer not null default 20 check (max_players between 2 and 50),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  closed_at timestamptz
);

create table if not exists public.room_players (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null check (char_length(trim(display_name)) between 2 and 32),
  team_id uuid,
  is_host boolean not null default false,
  player_order integer,
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  unique (room_id, user_id)
);

create index if not exists rooms_host_user_id_idx on public.rooms(host_user_id);
create index if not exists rooms_status_idx on public.rooms(status);
create index if not exists rooms_code_idx on public.rooms(code);
create index if not exists room_players_room_id_idx on public.room_players(room_id);
create index if not exists room_players_user_id_idx on public.room_players(user_id);
create index if not exists room_players_room_left_idx on public.room_players(room_id, left_at);

create trigger rooms_set_updated_at
before update on public.rooms
for each row
execute function public.set_updated_at();

create or replace function public.get_profile_for_auth_user()
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
begin
  select *
  into v_profile
  from public.profiles
  where id = auth.uid();

  if v_profile.id is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return v_profile;
end;
$$;

create or replace function public.generate_room_code()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_attempts integer := 0;
begin
  loop
    v_attempts := v_attempts + 1;
    v_code := lpad((floor(random() * 10000))::int::text, 4, '0');

    if not exists (
      select 1
      from public.rooms
      where code = v_code
        and status <> 'closed'
        and closed_at is null
    ) then
      return v_code;
    end if;

    if v_attempts > 50 then
      raise exception 'ROOM_CODE_GENERATION_FAILED';
    end if;
  end loop;
end;
$$;

create or replace function public.is_room_member(p_room_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.room_players rp
    where rp.room_id = p_room_id
      and rp.user_id = coalesce(p_user_id, auth.uid())
      and rp.left_at is null
  );
$$;

create or replace function public.is_room_host(p_room_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.rooms r
    where r.id = p_room_id
      and r.host_user_id = coalesce(p_user_id, auth.uid())
  );
$$;

create or replace function public.create_room()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles;
  v_room public.rooms;
  v_membership public.room_players;
  v_code text;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  v_profile := public.get_profile_for_auth_user();
  v_code := public.generate_room_code();

  insert into public.rooms (
    code,
    host_user_id
  ) values (
    v_code,
    v_uid
  )
  returning * into v_room;

  insert into public.room_players (
    room_id,
    user_id,
    display_name,
    is_host,
    player_order
  ) values (
    v_room.id,
    v_uid,
    v_profile.display_name,
    true,
    1
  )
  on conflict (room_id, user_id)
  do update set
    display_name = excluded.display_name,
    is_host = true,
    left_at = null
  returning * into v_membership;

  return jsonb_build_object(
    'room', to_jsonb(v_room),
    'membership', to_jsonb(v_membership)
  );
exception
  when unique_violation then
    raise exception 'ROOM_CREATE_CONFLICT';
end;
$$;

create or replace function public.join_room(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles;
  v_room public.rooms;
  v_membership public.room_players;
  v_active_players integer;
  v_code text;
  v_order integer;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  v_code := trim(p_code);
  if v_code !~ '^[0-9]{4}$' then
    raise exception 'INVALID_ROOM_CODE';
  end if;

  v_profile := public.get_profile_for_auth_user();

  select *
  into v_room
  from public.rooms
  where code = v_code
  limit 1;

  if v_room.id is null then
    raise exception 'ROOM_NOT_FOUND';
  end if;

  if v_room.status in ('finished', 'closed') or v_room.closed_at is not null then
    raise exception 'ROOM_CLOSED';
  end if;

  select count(*)::integer
  into v_active_players
  from public.room_players
  where room_id = v_room.id
    and left_at is null;

  select *
  into v_membership
  from public.room_players
  where room_id = v_room.id
    and user_id = v_uid
  limit 1;

  if v_membership.id is not null then
    update public.room_players
    set
      display_name = v_profile.display_name,
      left_at = null
    where id = v_membership.id
    returning * into v_membership;

    return jsonb_build_object(
      'room', to_jsonb(v_room),
      'membership', to_jsonb(v_membership)
    );
  end if;

  if v_active_players >= v_room.max_players then
    raise exception 'ROOM_FULL';
  end if;

  select coalesce(max(player_order), 0) + 1
  into v_order
  from public.room_players
  where room_id = v_room.id;

  insert into public.room_players (
    room_id,
    user_id,
    display_name,
    is_host,
    player_order
  ) values (
    v_room.id,
    v_uid,
    v_profile.display_name,
    false,
    v_order
  )
  returning * into v_membership;

  return jsonb_build_object(
    'room', to_jsonb(v_room),
    'membership', to_jsonb(v_membership)
  );
end;
$$;

create or replace function public.leave_room(p_room_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_room public.rooms;
  v_membership public.room_players;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  select * into v_room from public.rooms where id = p_room_id limit 1;
  if v_room.id is null then
    raise exception 'ROOM_NOT_FOUND';
  end if;

  select *
  into v_membership
  from public.room_players
  where room_id = p_room_id
    and user_id = v_uid
  limit 1;

  if v_membership.id is null then
    raise exception 'MEMBERSHIP_NOT_FOUND';
  end if;

  update public.room_players
  set left_at = now()
  where id = v_membership.id
  returning * into v_membership;

  if v_room.host_user_id = v_uid and v_room.status = 'lobby' then
    update public.rooms
    set
      status = 'closed',
      closed_at = now(),
      updated_at = now()
    where id = v_room.id
    returning * into v_room;
  end if;

  return jsonb_build_object(
    'room', to_jsonb(v_room),
    'membership', to_jsonb(v_membership)
  );
end;
$$;

create or replace function public.update_room_settings(
  p_room_id uuid,
  p_mode text,
  p_timer_seconds integer,
  p_skip_penalty_seconds integer,
  p_rounds_to_win integer,
  p_difficulty text,
  p_testament text,
  p_show_question_to_opponents boolean
)
returns public.rooms
language plpgsql
security definer
set search_path = public
as $$
declare
  v_room public.rooms;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if not public.is_room_host(p_room_id, auth.uid()) then
    raise exception 'HOST_ONLY';
  end if;

  update public.rooms
  set
    mode = p_mode,
    timer_seconds = p_timer_seconds,
    skip_penalty_seconds = p_skip_penalty_seconds,
    rounds_to_win = p_rounds_to_win,
    difficulty = p_difficulty,
    testament = p_testament,
    show_question_to_opponents = p_show_question_to_opponents,
    updated_at = now()
  where id = p_room_id
    and status in ('lobby', 'team_selection')
  returning * into v_room;

  if v_room.id is null then
    raise exception 'ROOM_UPDATE_NOT_ALLOWED';
  end if;

  return v_room;
end;
$$;

alter table public.rooms enable row level security;
alter table public.room_players enable row level security;

create policy "rooms_select_member"
on public.rooms
for select
using (public.is_room_member(id));

create policy "room_players_select_member"
on public.room_players
for select
using (public.is_room_member(room_id) or user_id = auth.uid());

revoke insert, update, delete on public.rooms from authenticated;
revoke insert, update, delete on public.room_players from authenticated;

grant execute on function public.get_profile_for_auth_user() to authenticated;
grant execute on function public.generate_room_code() to authenticated;
grant execute on function public.is_room_member(uuid, uuid) to authenticated;
grant execute on function public.is_room_host(uuid, uuid) to authenticated;
grant execute on function public.create_room() to authenticated;
grant execute on function public.join_room(text) to authenticated;
grant execute on function public.leave_room(uuid) to authenticated;
grant execute on function public.update_room_settings(uuid, text, integer, integer, integer, text, text, boolean) to authenticated;
