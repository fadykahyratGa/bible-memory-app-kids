-- Core profile/admin table
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists podcasts (
  id text primary key,
  name text not null,
  icon_url text,
  podbean_url text not null unique,
  is_christian boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists favorite_podcasts (
  user_id uuid not null references auth.users(id) on delete cascade,
  podcast_id text not null references podcasts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, podcast_id)
);

create table if not exists episodes (
  id uuid primary key default gen_random_uuid(),
  podcast_id text not null references podcasts(id) on delete cascade,
  title text not null,
  episode_url text not null unique,
  icon_url text,
  published_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table if not exists episode_user_meta (
  user_id uuid not null references auth.users(id) on delete cascade,
  episode_id uuid not null references episodes(id) on delete cascade,
  is_favorite boolean not null default false,
  rating int not null default 0 check (rating between 0 and 5),
  hashtag text,
  updated_at timestamptz not null default now(),
  primary key (user_id, episode_id)
);

create table if not exists scrape_runs (
  id bigint generated always as identity primary key,
  run_at timestamptz not null default now(),
  trigger_source text not null default 'cron',
  status text not null default 'queued'
);

alter table profiles enable row level security;
alter table podcasts enable row level security;
alter table favorite_podcasts enable row level security;
alter table episodes enable row level security;
alter table episode_user_meta enable row level security;

-- Helper function
create or replace function is_admin(uid uuid)
returns boolean
language sql
stable
as $$
  select exists(select 1 from profiles p where p.id = uid and p.is_admin = true);
$$;

-- Profiles policies
create policy "users read own profile"
on profiles for select
using (auth.uid() = id);

create policy "users insert own profile"
on profiles for insert
with check (auth.uid() = id and is_admin = false);

create policy "admins update profiles"
on profiles for update
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

-- Podcasts policies
create policy "users can read podcasts"
on podcasts for select
using (true);

create policy "admins manage podcasts"
on podcasts for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

-- Favorite podcast policies
create policy "users read own favorite podcasts"
on favorite_podcasts for select
using (auth.uid() = user_id or is_admin(auth.uid()));

create policy "users manage own favorite podcasts"
on favorite_podcasts for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Episode policies
create policy "users can read episodes"
on episodes for select
using (true);

create policy "admins manage episodes"
on episodes for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

-- Per-user episode metadata policies
create policy "users read own episode meta"
on episode_user_meta for select
using (auth.uid() = user_id);

create policy "users manage own episode meta"
on episode_user_meta for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Scheduler support (requires pg_cron + pg_net in Supabase)
create extension if not exists pg_cron;
create extension if not exists pg_net;

create or replace function trigger_scrape_refresh()
returns void
language plpgsql
security definer
as $$
declare
  project_url text := current_setting('app.settings.supabase_url', true);
  service_role_key text := current_setting('app.settings.service_role_key', true);
begin
  insert into scrape_runs (trigger_source, status) values ('cron', 'queued');

  perform
    net.http_post(
      url := project_url || '/functions/v1/scrape-refresh',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_role_key
      ),
      body := '{}'::jsonb
    );
end;
$$;

-- Runs every 12h: 00:00 UTC and 12:00 UTC
do $$
begin
  if not exists (select 1 from cron.job where jobname = 'podcast-scrape-midnight') then
    perform cron.schedule('podcast-scrape-midnight', '0 0 * * *', $$select trigger_scrape_refresh();$$);
  end if;

  if not exists (select 1 from cron.job where jobname = 'podcast-scrape-noon') then
    perform cron.schedule('podcast-scrape-noon', '0 12 * * *', $$select trigger_scrape_refresh();$$);
  end if;
end $$;
