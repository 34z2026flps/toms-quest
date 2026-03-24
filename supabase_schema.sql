-- Tom's Quest Board — Supabase Schema
-- Run this in Supabase: SQL Editor → New query → paste all → Run

-- Drop existing tables (safe re-run)
drop table if exists mood_log;
drop table if exists tasks;
drop table if exists quest_state;

-- Quest state (one row per student)
create table quest_state (
  id text primary key default 'tom',
  xp integer default 0,
  level integer default 1,
  avatar jsonb default '{}'::jsonb,
  owned_items text[] default array['skin_light','hair_black','top_blue','bot_jeans','hat_none','acc_none','bg_plain']::text[],
  home_layout jsonb default '[]'::jsonb,
  monster_collection jsonb default '{}'::jsonb,
  active_monster_id text default null,
  monster_packs integer default 0,
  starter_chosen boolean default false,
  updated_at timestamptz default now()
);

-- Tasks
create table tasks (
  id serial primary key,
  day_index integer not null default 0 check (day_index between 0 and 4),
  subject text not null default 'Writing',
  name text not null default 'New Task',
  meta text default '',
  xp integer default 25,
  steps integer default 1,
  progress integer default 0,
  done boolean default false,
  link text default '',
  activity_content text default '',
  min_words integer default 50,
  saved_writing text default '',
  submitted_at text default '',
  unlocks_games text[] default array[]::text[],
  updated_at timestamptz default now()
);

-- Mood log
create table mood_log (
  id serial primary key,
  mood text not null,
  emoji text not null,
  is_alert boolean default false,
  logged_at timestamptz default now()
);

-- Seed default state row for Tom
insert into quest_state (id) values ('tom') on conflict (id) do nothing;

-- Row Level Security (allow all for this app)
alter table quest_state enable row level security;
alter table tasks enable row level security;
alter table mood_log enable row level security;

create policy "allow_all" on quest_state for all using (true) with check (true);
create policy "allow_all" on tasks for all using (true) with check (true);
create policy "allow_all" on mood_log for all using (true) with check (true);
