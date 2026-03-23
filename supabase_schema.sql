-- Tom's Quest Board — Supabase Schema
-- Run this in your Supabase SQL editor (Dashboard → SQL Editor → New query)

-- Main state table (one row per student)
create table if not exists quest_state (
  id text primary key default 'tom',
  xp integer default 120,
  active_monster_id text default null,
  monster_packs integer default 0,
  avatar jsonb default '{"skin":"skin_light","top":"top_blue","hat":"hat_none","accessory":"acc_none","bg":"bg_plain","pet":null}'::jsonb,
  owned_items jsonb default '["skin_light","skin_medium","skin_dark","skin_tan","hair_black","top_none","top_blue","top_red","hat_none","acc_none","bg_plain"]'::jsonb,
  home_layout jsonb default '[]'::jsonb,
  monster_collection jsonb default '{}'::jsonb,
  starter_chosen boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Tasks table (teacher edits these remotely)
create table if not exists tasks (
  id serial primary key,
  student_id text default 'tom',
  day_index integer not null check (day_index between 0 and 4), -- 0=Mon 4=Fri
  subject text not null default 'Reading',
  name text not null default 'New task',
  meta text default '',
  xp integer default 20,
  steps integer default 3,
  progress integer default 0,
  done boolean default false,
  link text default '',
  ws_data text default '',       -- base64 worksheet image
  gate_session text default '',  -- morning|recess|lunch
  activity_content text default '',
  min_words integer default 30,
  saved_writing text default '',
  writing_submitted_at text default '',
  video_answers jsonb default '[]'::jsonb,
  annotation text default '',    -- worksheet drawing
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Mood log table
create table if not exists mood_log (
  id serial primary key,
  student_id text default 'tom',
  mood_id text not null,
  mood_label text not null,
  mood_emoji text not null,
  is_alert boolean default false,
  time_id text default 'manual',
  logged_at timestamptz default now()
);

-- Insert default state if not exists
insert into quest_state (id) values ('tom') on conflict (id) do nothing;

-- Insert default tasks for Monday (day 0)
insert into tasks (student_id, day_index, subject, name, meta, xp, steps, gate_session, activity_content, min_words) values
  ('tom', 0, 'Reading', 'Chapter 3 — The Lost Map', '15 min read', 30, 3, 'morning', 'The Lost Map

Tom and his best friend Kai found an old map tucked behind a loose brick in the school library wall. The edges were worn and brown, like it had been there for hundreds of years.

They agreed to investigate after school. The first clue was scratched underneath the map — three words in Latin. Tom raced to the dictionary. The translation made him gasp: The key moves.

Outside, the old oak tree stood as still as ever. But when the afternoon wind shifted, one branch swung like a pendulum — always pointing in the same direction. North, said Kai quietly.', 30),
  ('tom', 0, 'Maths', 'Multiplication Tables ×7', '10 questions', 25, 5, 'recess', '7 × 3|21
7 × 6|42
7 × 8|56
7 × 4|28
7 × 9|63
7 × 7|49
7 × 11|77
7 × 5|35
7 × 12|84
7 × 2|14', 30),
  ('tom', 0, 'Writing', 'Write about your hero', '5 sentences', 35, 5, 'lunch', 'Think about a person you look up to — a hero. This could be someone real (a family member, a sports star, a scientist) or a character from a book or film. Write about why you admire them, what makes them special, and what you could learn from them.', 40),
  ('tom', 0, 'Video', 'How volcanoes work', '8 min video', 20, 1, '', '', 30)
on conflict do nothing;

-- Enable Row Level Security (RLS) — public read/write for simplicity
-- (You can tighten this later with auth)
alter table quest_state enable row level security;
alter table tasks enable row level security;
alter table mood_log enable row level security;

create policy "Public read quest_state" on quest_state for select using (true);
create policy "Public write quest_state" on quest_state for all using (true);
create policy "Public read tasks" on tasks for select using (true);
create policy "Public write tasks" on tasks for all using (true);
create policy "Public write mood_log" on mood_log for insert with check (true);
create policy "Public read mood_log" on mood_log for select using (true);
