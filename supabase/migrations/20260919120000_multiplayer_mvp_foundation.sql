create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  host_user_id uuid not null references auth.users(id) on delete restrict,
  judge_user_id uuid references auth.users(id) on delete set null,
  game_mode text not null check (game_mode in ('individual', 'teams')),
  judge_mode text not null check (judge_mode in ('none', 'host', 'dedicated')),
  status text not null default 'waiting' check (status in ('waiting', 'starting', 'playing', 'finished')),
  is_private boolean not null default true,
  team_count integer check (team_count between 2 and 4),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rooms_code_format check (code ~ '^[A-Z2-9]{5,6}$')
);

create table if not exists public.room_teams (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  team_number integer not null,
  name text not null,
  score integer not null default 0,
  created_at timestamptz not null default now(),
  unique (room_id, team_number)
);

create table if not exists public.room_players (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_id text,
  team_id uuid references public.room_teams(id) on delete set null,
  score integer not null default 0,
  is_host boolean not null default false,
  is_judge boolean not null default false,
  is_ready boolean not null default false,
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  unique (room_id, user_id)
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  state text not null default 'waiting' check (state in ('waiting', 'starting', 'playing', 'answering', 'reviewing', 'round_results', 'game_results', 'paused', 'finished')),
  current_round_order integer not null default 1,
  current_challenge_order integer not null default 1,
  current_challenge_started_at timestamptz,
  current_challenge_ends_at timestamptz,
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.game_rounds (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  round_order integer not null,
  title text not null,
  created_at timestamptz not null default now(),
  unique (game_id, round_order)
);

create table if not exists public.game_challenges (
  id uuid primary key default gen_random_uuid(),
  round_id uuid not null references public.game_rounds(id) on delete cascade,
  challenge_order integer not null,
  type text not null check (type in ('multiple_choice', 'true_false')),
  prompt text not null,
  options jsonb not null default '[]'::jsonb,
  correct_answer text not null,
  metadata jsonb not null default '{}'::jsonb,
  points integer not null default 10,
  created_at timestamptz not null default now(),
  unique (round_id, challenge_order)
);

create table if not exists public.player_answers (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  game_id uuid not null references public.games(id) on delete cascade,
  challenge_id uuid not null references public.game_challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answer_text text not null,
  is_correct boolean not null default false,
  points_awarded integer not null default 0,
  answered_at timestamptz not null default now(),
  unique (challenge_id, user_id)
);

create table if not exists public.score_events (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  game_id uuid not null references public.games(id) on delete cascade,
  challenge_id uuid references public.game_challenges(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade,
  team_id uuid references public.room_teams(id) on delete set null,
  points_delta integer not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.user_progress (
  user_id uuid primary key references public.users(id) on delete cascade,
  total_verses_completed integer not null default 0,
  total_games_played integer not null default 0,
  total_score integer not null default 0,
  current_level integer not null default 1,
  last_game_config jsonb
);

create table if not exists public.favorites (
  user_id uuid not null references public.users(id) on delete cascade,
  verse_ref text not null,
  primary key (user_id, verse_ref)
);

create table if not exists public.badges (
  id text primary key,
  name_ar text not null,
  description_ar text not null,
  icon_key text,
  condition_type text,
  condition_value integer
);

create table if not exists public.user_badges (
  user_id uuid not null references public.users(id) on delete cascade,
  badge_id text not null references public.badges(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

create table if not exists public.settings (
  user_id uuid primary key references public.users(id) on delete cascade,
  default_difficulty text not null default 'easy',
  sound_enabled boolean not null default true
);

create index if not exists rooms_code_idx on public.rooms(code);
create index if not exists rooms_host_user_id_idx on public.rooms(host_user_id);
create index if not exists room_players_room_id_idx on public.room_players(room_id);
create index if not exists room_players_user_id_idx on public.room_players(user_id);
create index if not exists room_players_team_id_idx on public.room_players(team_id);
create index if not exists games_room_id_idx on public.games(room_id);
create index if not exists game_rounds_game_id_idx on public.game_rounds(game_id);
create index if not exists game_challenges_round_id_idx on public.game_challenges(round_id);
create index if not exists player_answers_challenge_user_idx on public.player_answers(challenge_id, user_id);
create index if not exists score_events_room_id_idx on public.score_events(room_id);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists rooms_set_updated_at on public.rooms;
create trigger rooms_set_updated_at
before update on public.rooms
for each row execute function public.set_updated_at();

drop trigger if exists games_set_updated_at on public.games;
create trigger games_set_updated_at
before update on public.games
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.room_players enable row level security;
alter table public.room_teams enable row level security;
alter table public.games enable row level security;
alter table public.game_rounds enable row level security;
alter table public.game_challenges enable row level security;
alter table public.player_answers enable row level security;
alter table public.score_events enable row level security;
alter table public.users enable row level security;
alter table public.user_progress enable row level security;
alter table public.favorites enable row level security;
alter table public.badges enable row level security;
alter table public.user_badges enable row level security;
alter table public.settings enable row level security;

create or replace function public.is_room_member(target_room_id uuid)
returns boolean
language sql
stable
as $$
  select exists(
    select 1
    from public.room_players
    where room_id = target_room_id
      and user_id = auth.uid()
      and left_at is null
  );
$$;

create policy "profiles_select_own_or_room_members"
on public.profiles for select
using (
  auth.uid() = id
  or exists (
    select 1
    from public.room_players rp
    join public.room_players self on self.room_id = rp.room_id and self.user_id = auth.uid() and self.left_at is null
    where rp.user_id = profiles.id and rp.left_at is null
  )
);

create policy "profiles_insert_own"
on public.profiles for insert
with check (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "rooms_select_members"
on public.rooms for select
using (public.is_room_member(id) or host_user_id = auth.uid());

create policy "room_players_select_members"
on public.room_players for select
using (public.is_room_member(room_id) or user_id = auth.uid());

create policy "room_players_update_self"
on public.room_players for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "room_teams_select_members"
on public.room_teams for select
using (public.is_room_member(room_id));

create policy "games_select_members"
on public.games for select
using (public.is_room_member(room_id));

create policy "game_rounds_select_members"
on public.game_rounds for select
using (
  exists (
    select 1 from public.games g
    where g.id = game_rounds.game_id
      and public.is_room_member(g.room_id)
  )
);

create policy "game_challenges_select_members"
on public.game_challenges for select
using (
  exists (
    select 1
    from public.game_rounds gr
    join public.games g on g.id = gr.game_id
    where gr.id = game_challenges.round_id
      and public.is_room_member(g.room_id)
  )
);

create policy "player_answers_select_scoped"
on public.player_answers for select
using (
  user_id = auth.uid()
  or exists (
    select 1
    from public.games g
    where g.id = player_answers.game_id
      and g.state in ('reviewing', 'round_results', 'game_results', 'finished')
      and public.is_room_member(player_answers.room_id)
  )
);

create policy "score_events_select_members"
on public.score_events for select
using (public.is_room_member(room_id));

create policy "users_select_own"
on public.users for select using (auth.uid() = id);
create policy "users_insert_own"
on public.users for insert with check (auth.uid() = id);

create policy "user_progress_own"
on public.user_progress for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "favorites_own"
on public.favorites for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "badges_public_read"
on public.badges for select using (true);

create policy "user_badges_own"
on public.user_badges for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "settings_own"
on public.settings for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.find_room_by_code(p_room_code text)
returns public.rooms
language sql
security definer
set search_path = public
as $$
  select *
  from public.rooms
  where code = upper(trim(p_room_code))
  limit 1;
$$;

create or replace function public.get_current_challenge(p_room_id uuid)
returns table (
  id uuid,
  round_id uuid,
  challenge_order integer,
  type text,
  prompt text,
  options jsonb,
  correct_answer text,
  metadata jsonb,
  points integer
)
language sql
security definer
set search_path = public
as $$
  select gc.id, gc.round_id, gc.challenge_order, gc.type, gc.prompt, gc.options, gc.correct_answer, gc.metadata, gc.points
  from public.games g
  join public.game_rounds gr on gr.game_id = g.id and gr.round_order = g.current_round_order
  join public.game_challenges gc on gc.round_id = gr.id and gc.challenge_order = g.current_challenge_order
  where g.room_id = p_room_id
  order by g.created_at desc
  limit 1;
$$;

create or replace function public.generate_room_code(code_length integer default 6)
returns text
language plpgsql
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  candidate text := '';
  i integer;
begin
  if code_length not in (5, 6) then
    raise exception 'INVALID_ROOM_CODE_LENGTH';
  end if;

  loop
    candidate := '';
    for i in 1..code_length loop
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::integer, 1);
    end loop;
    exit when not exists (select 1 from public.rooms where code = candidate);
  end loop;

  return candidate;
end;
$$;

create or replace function public.ensure_base_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id)
  values (auth.uid())
  on conflict (id) do nothing;
end;
$$;

create or replace function public.ensure_profile_name(input_display_name text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  resolved_name text;
begin
  select display_name into resolved_name from public.profiles where id = auth.uid();
  resolved_name := coalesce(nullif(trim(input_display_name), ''), resolved_name);
  if resolved_name is null then
    raise exception 'PROFILE_REQUIRED';
  end if;
  return resolved_name;
end;
$$;

create or replace function public.auto_assign_teams(p_room_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  player_record record;
  target_team_id uuid;
begin
  if not exists (select 1 from public.rooms where id = p_room_id and host_user_id = auth.uid()) then
    raise exception 'NOT_HOST';
  end if;

  for player_record in
    select rp.id
    from public.room_players rp
    where rp.room_id = p_room_id
      and rp.left_at is null
      and rp.team_id is null
    order by rp.joined_at asc
  loop
    select rt.id
      into target_team_id
    from public.room_teams rt
    left join public.room_players rp on rp.team_id = rt.id and rp.left_at is null
    where rt.room_id = p_room_id
    group by rt.id, rt.team_number
    order by count(rp.id) asc, rt.team_number asc
    limit 1;

    update public.room_players
    set team_id = target_team_id
    where id = player_record.id;
  end loop;
end;
$$;

create or replace function public.assign_room_team(p_room_id uuid, p_user_id uuid, p_team_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.rooms where id = p_room_id and host_user_id = auth.uid()) then
    raise exception 'NOT_HOST';
  end if;

  if not exists (select 1 from public.room_teams where id = p_team_id and room_id = p_room_id) then
    raise exception 'TEAM_NOT_FOUND';
  end if;

  update public.room_players
  set team_id = p_team_id
  where room_id = p_room_id and user_id = p_user_id and left_at is null;
end;
$$;

create or replace function public.create_room(
  p_game_mode text,
  p_judge_mode text,
  p_team_count integer default null,
  p_is_private boolean default true
)
returns table (room_id uuid, room_code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  new_room_id uuid := gen_random_uuid();
  new_code text := public.generate_room_code(6);
  player_name text;
  idx integer;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  perform public.ensure_base_user();
  player_name := public.ensure_profile_name(null);

  insert into public.rooms (id, code, host_user_id, judge_user_id, game_mode, judge_mode, team_count, is_private)
  values (
    new_room_id,
    new_code,
    auth.uid(),
    case when p_judge_mode = 'dedicated' then auth.uid() else null end,
    p_game_mode,
    p_judge_mode,
    case when p_game_mode = 'teams' then p_team_count else null end,
    p_is_private
  );

  insert into public.room_players (room_id, user_id, display_name, avatar_id, is_host, is_judge)
  select new_room_id, auth.uid(), p.display_name, p.avatar_id, true, p_judge_mode in ('host', 'dedicated')
  from public.profiles p
  where p.id = auth.uid();

  if p_game_mode = 'teams' then
    for idx in 1..coalesce(p_team_count, 2) loop
      insert into public.room_teams (room_id, team_number, name)
      values (new_room_id, idx, 'الفريق ' || idx);
    end loop;
    perform public.auto_assign_teams(new_room_id);
  end if;

  return query select new_room_id, new_code;
end;
$$;

create or replace function public.join_room(p_room_code text, p_display_name text default null)
returns table (room_id uuid, room_code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  target_room public.rooms%rowtype;
  resolved_name text;
  assigned_team_id uuid;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  perform public.ensure_base_user();
  resolved_name := public.ensure_profile_name(p_display_name);

  select * into target_room
  from public.find_room_by_code(p_room_code);

  if target_room.id is null then
    raise exception 'ROOM_NOT_FOUND';
  end if;

  if target_room.status <> 'waiting' then
    raise exception 'ROOM_STARTED';
  end if;

  if target_room.game_mode = 'teams' then
    select rt.id
      into assigned_team_id
    from public.room_teams rt
    left join public.room_players rp on rp.team_id = rt.id and rp.left_at is null
    where rt.room_id = target_room.id
    group by rt.id, rt.team_number
    order by count(rp.id) asc, rt.team_number asc
    limit 1;
  end if;

  insert into public.room_players (room_id, user_id, display_name, avatar_id, team_id, is_host, is_judge, left_at)
  values (
    target_room.id,
    auth.uid(),
    resolved_name,
    (select avatar_id from public.profiles where id = auth.uid()),
    assigned_team_id,
    false,
    false,
    null
  )
  on conflict (room_id, user_id)
  do update set
    display_name = excluded.display_name,
    avatar_id = excluded.avatar_id,
    team_id = coalesce(public.room_players.team_id, excluded.team_id),
    is_host = false,
    is_judge = false,
    left_at = null;

  return query select target_room.id, target_room.code;
end;
$$;

create or replace function public.leave_room(p_room_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  next_host uuid;
  current_judge uuid;
  current_judge_mode text;
begin
  update public.room_players
  set left_at = now(), is_host = false, is_judge = false
  where room_id = p_room_id and user_id = auth.uid();

  select judge_user_id, judge_mode into current_judge, current_judge_mode
  from public.rooms
  where id = p_room_id;

  if exists (select 1 from public.rooms where id = p_room_id and host_user_id = auth.uid()) then
    select user_id into next_host
    from public.room_players
    where room_id = p_room_id and left_at is null
    order by joined_at asc
    limit 1;

    update public.rooms
    set host_user_id = coalesce(next_host, host_user_id),
        status = case when next_host is null then 'finished' else status end
    where id = p_room_id;

    if next_host is not null then
      update public.room_players
      set is_host = true,
          is_judge = case when current_judge_mode = 'host' then true else is_judge end
      where room_id = p_room_id and user_id = next_host;

      update public.rooms
      set judge_user_id = case
            when current_judge_mode = 'host' then next_host
            when current_judge_mode = 'dedicated' and current_judge = auth.uid() then next_host
            else judge_user_id
          end
      where id = p_room_id;

      if current_judge_mode = 'dedicated' and current_judge = auth.uid() then
        update public.room_players
        set is_judge = true
        where room_id = p_room_id and user_id = next_host;
      end if;
    else
      update public.rooms
      set judge_user_id = null
      where id = p_room_id;
    end if;
  elsif current_judge_mode = 'dedicated' and current_judge = auth.uid() then
    select user_id into next_host
    from public.room_players
    where room_id = p_room_id and left_at is null
    order by joined_at asc
    limit 1;

    update public.rooms
    set judge_user_id = next_host
    where id = p_room_id;

    if next_host is not null then
      update public.room_players
      set is_judge = true
      where room_id = p_room_id and user_id = next_host;
    end if;
  end if;
end;
$$;

create or replace function public.start_room_game(p_room_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  game_id uuid := gen_random_uuid();
  round_id uuid := gen_random_uuid();
begin
  if not exists (select 1 from public.rooms where id = p_room_id and host_user_id = auth.uid()) then
    raise exception 'NOT_HOST';
  end if;

  if exists (select 1 from public.rooms where id = p_room_id and status <> 'waiting') then
    raise exception 'ROOM_STARTED';
  end if;

  update public.rooms
  set status = 'playing'
  where id = p_room_id;

  insert into public.games (id, room_id, state, started_at, current_round_order, current_challenge_order, current_challenge_started_at, current_challenge_ends_at)
  values (game_id, p_room_id, 'playing', now(), 1, 1, now(), now() + interval '45 seconds');

  insert into public.game_rounds (id, game_id, round_order, title)
  values (round_id, game_id, 1, 'الجولة الأولى');

  insert into public.game_challenges (round_id, challenge_order, type, prompt, options, correct_answer, points)
  values
    (round_id, 1, 'multiple_choice', 'من الذي بنى الفلك؟', '["نوح","إبراهيم","موسى","داود"]'::jsonb, 'نوح', 10),
    (round_id, 2, 'true_false', 'صح أم خطأ: داود هزم جليات.', '["صح","خطأ"]'::jsonb, 'صح', 10);

  return game_id;
end;
$$;

create or replace function public.submit_answer(p_room_id uuid, p_challenge_id uuid, p_answer_text text)
returns table (is_correct boolean, points_awarded integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  active_game public.games%rowtype;
  challenge_record public.game_challenges%rowtype;
  team_id_value uuid;
  calculated_points integer := 0;
  previous_points integer := 0;
  score_delta integer := 0;
  answer_is_correct boolean := false;
begin
  if not exists (
    select 1
    from public.room_players
    where room_id = p_room_id and user_id = auth.uid() and left_at is null
  ) then
    raise exception 'ROOM_NOT_FOUND';
  end if;

  select * into active_game
  from public.games
  where room_id = p_room_id
  order by created_at desc
  limit 1;

  if active_game.id is null then
    raise exception 'GAME_NOT_FOUND';
  end if;

  select * into challenge_record
  from public.game_challenges
  where id = p_challenge_id;

  if challenge_record.id is null then
    raise exception 'CHALLENGE_NOT_FOUND';
  end if;

  if not exists (
    select 1
    from public.game_rounds gr
    where gr.id = challenge_record.round_id
      and gr.game_id = active_game.id
      and gr.round_order = active_game.current_round_order
      and challenge_record.challenge_order = active_game.current_challenge_order
  ) then
    raise exception 'CHALLENGE_NOT_ACTIVE';
  end if;

  answer_is_correct := trim(p_answer_text) = challenge_record.correct_answer;
  calculated_points := case when answer_is_correct then challenge_record.points else 0 end;

  select team_id into team_id_value
  from public.room_players
  where room_id = p_room_id and user_id = auth.uid();

  select coalesce(points_awarded, 0) into previous_points
  from public.player_answers
  where challenge_id = p_challenge_id and user_id = auth.uid();

  insert into public.player_answers (room_id, game_id, challenge_id, user_id, answer_text, is_correct, points_awarded)
  values (p_room_id, active_game.id, p_challenge_id, auth.uid(), trim(p_answer_text), answer_is_correct, calculated_points)
  on conflict (challenge_id, user_id)
  do update set
    answer_text = excluded.answer_text,
    is_correct = excluded.is_correct,
    points_awarded = excluded.points_awarded,
    answered_at = now();

  score_delta := calculated_points - previous_points;

  if score_delta <> 0 then
    update public.room_players
    set score = score + score_delta
    where room_id = p_room_id and user_id = auth.uid();

    if team_id_value is not null then
      update public.room_teams
      set score = score + score_delta
      where id = team_id_value;
    end if;

    insert into public.score_events (room_id, game_id, challenge_id, user_id, team_id, points_delta, reason)
    values (p_room_id, active_game.id, p_challenge_id, auth.uid(), team_id_value, score_delta, 'answer_submission');
  end if;

  return query select answer_is_correct, calculated_points;
end;
$$;

create or replace function public.advance_challenge(p_room_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  active_game public.games%rowtype;
  total_challenges integer;
begin
  if not exists (select 1 from public.rooms where id = p_room_id and host_user_id = auth.uid()) then
    raise exception 'NOT_HOST';
  end if;

  select * into active_game
  from public.games
  where room_id = p_room_id
  order by created_at desc
  limit 1;

  if active_game.id is null then
    raise exception 'GAME_NOT_FOUND';
  end if;

  select count(*) into total_challenges
  from public.game_challenges gc
  join public.game_rounds gr on gr.id = gc.round_id
  where gr.game_id = active_game.id and gr.round_order = active_game.current_round_order;

  if active_game.current_challenge_order < total_challenges then
    update public.games
    set current_challenge_order = current_challenge_order + 1,
        state = 'playing',
        current_challenge_started_at = now(),
        current_challenge_ends_at = now() + interval '45 seconds'
    where id = active_game.id;
  else
    update public.games
    set state = 'game_results',
        ended_at = now()
    where id = active_game.id;

    update public.rooms
    set status = 'finished'
    where id = p_room_id;
  end if;
end;
$$;

grant execute on function public.create_room(text, text, integer, boolean) to authenticated;
grant execute on function public.join_room(text, text) to authenticated;
grant execute on function public.leave_room(uuid) to authenticated;
grant execute on function public.start_room_game(uuid) to authenticated;
grant execute on function public.submit_answer(uuid, uuid, text) to authenticated;
grant execute on function public.advance_challenge(uuid) to authenticated;
grant execute on function public.assign_room_team(uuid, uuid, uuid) to authenticated;
grant execute on function public.auto_assign_teams(uuid) to authenticated;
grant execute on function public.get_current_challenge(uuid) to authenticated;
