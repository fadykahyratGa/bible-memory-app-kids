create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(trim(display_name)) between 2 and 32),
  avatar_url text,
  is_guest boolean not null default true,
  games_played integer not null default 0 check (games_played >= 0),
  wins integer not null default 0 check (wins >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

alter table public.profiles enable row level security;

create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = id);

create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

create or replace function public.upsert_profile(
  p_display_name text,
  p_is_guest boolean default true
)
returns public.profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid uuid;
  v_profile public.profiles;
begin
  v_uid := auth.uid();

  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if p_display_name is null or char_length(trim(p_display_name)) < 2 then
    raise exception 'INVALID_DISPLAY_NAME';
  end if;

  insert into public.profiles (
    id,
    display_name,
    is_guest
  )
  values (
    v_uid,
    trim(p_display_name),
    p_is_guest
  )
  on conflict (id)
  do update set
    display_name = excluded.display_name,
    is_guest = excluded.is_guest,
    updated_at = now()
  returning * into v_profile;

  return v_profile;
end;
$$;

create or replace function public.upgrade_guest_profile_if_needed(
  p_display_name text default null
)
returns public.profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid uuid;
  v_profile public.profiles;
begin
  v_uid := auth.uid();

  if v_uid is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  update public.profiles
  set
    is_guest = false,
    display_name = coalesce(nullif(trim(p_display_name), ''), display_name),
    updated_at = now()
  where id = v_uid
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return v_profile;
end;
$$;

grant execute on function public.upsert_profile(text, boolean) to authenticated;
grant execute on function public.upgrade_guest_profile_if_needed(text) to authenticated;
