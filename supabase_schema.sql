-- ================================================
-- Supabase SQL Schema for Bible Memory App for Kids
-- ================================================
-- This file contains the complete database schema for the app.
-- Run these commands in your Supabase SQL Editor.

-- ================================================
-- 1. Users Table
-- ================================================
-- Note: Supabase automatically creates the auth.users table
-- We create a reference table in the public schema
create table if not exists public.users (
  id uuid primary key references auth.users on delete cascade,
  created_at timestamptz default now()
);

-- ================================================
-- 2. Books Table
-- ================================================
-- Stores Bible book information
create table if not exists public.books (
  id serial primary key,
  numeric_id int unique not null,
  name_ar text not null,
  chapters_count int not null,
  created_at timestamptz default now()
);

-- Example: Insert books (Matthew as an example)
-- insert into books (numeric_id, name_ar, chapters_count) values
--   (50, 'إنجيل متى', 28),
--   (51, 'إنجيل مرقس', 16),
--   (52, 'إنجيل لوقا', 24),
--   (53, 'إنجيل يوحنا', 21);

-- ================================================
-- 3. Verses Table
-- ================================================
-- Stores Bible verses in Arabic
create table if not exists public.verses (
  id serial primary key,
  ref text unique not null,           -- Format: "bookId-chapter-verse" e.g., "50-5-3"
  book_id int not null,
  book_name text not null,
  chapter int not null,
  verse_number int not null,
  text_ar text not null,
  created_at timestamptz default now()
);

-- Example: Insert a verse (Matthew 5:3)
-- insert into verses (ref, book_id, book_name, chapter, verse_number, text_ar) values
--   ('50-5-3', 50, 'إنجيل متى', 5, 3, 'طُوبَى لِلْمَسَاكِينِ بِالرُّوحِ، لأَنَّ لَهُمْ مَلَكُوتَ السَّمَاوَاتِ.');

-- ================================================
-- 4. User Progress Table
-- ================================================
-- Tracks user's game progress and statistics
create table if not exists public.user_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  total_verses_completed int default 0,
  total_games_played int default 0,
  total_score int default 0,
  current_level int default 1,
  last_game_config jsonb,              -- Stores the last game configuration
  updated_at timestamptz default now()
);

-- Example last_game_config JSON:
-- {
--   "book": 50,
--   "bookName": "إنجيل متى",
--   "chapter": 5,
--   "fromVerse": 3,
--   "toVerse": 12,
--   "difficulty": "easy"
-- }

-- ================================================
-- 5. Favorites Table
-- ================================================
-- Stores user's favorite verses
create table if not exists public.favorites (
  user_id uuid references auth.users(id) on delete cascade,
  verse_ref text not null,             -- Reference to verse: "bookId-chapter-verse"
  created_at timestamptz default now(),
  primary key (user_id, verse_ref)
);

-- ================================================
-- 6. Badges Table
-- ================================================
-- Defines available achievement badges
create table if not exists public.badges (
  id text primary key,
  name_ar text not null,
  description_ar text not null,
  icon_key text,                       -- Icon identifier
  condition_type text,                 -- e.g., 'games_played', 'verses_completed', 'total_score'
  condition_value int                  -- Threshold to unlock badge
);

-- ================================================
-- 7. User Badges Table
-- ================================================
-- Tracks badges unlocked by each user
create table if not exists public.user_badges (
  user_id uuid references auth.users(id) on delete cascade,
  badge_id text references badges(id) on delete cascade,
  unlocked_at timestamptz default now(),
  primary key (user_id, badge_id)
);

-- ================================================
-- 8. Settings Table
-- ================================================
-- Stores user preferences
create table if not exists public.settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  default_difficulty text default 'easy',  -- 'easy', 'medium', 'hard'
  sound_enabled bool default true,
  updated_at timestamptz default now()
);

-- ================================================
-- 9. Indexes for Performance
-- ================================================
create index if not exists idx_verses_book_chapter on verses(book_id, chapter);
create index if not exists idx_verses_ref on verses(ref);
create index if not exists idx_favorites_user on favorites(user_id);
create index if not exists idx_user_badges_user on user_badges(user_id);
create index if not exists idx_user_progress_user on user_progress(user_id);

-- ================================================
-- 10. Enable Row Level Security (RLS)
-- ================================================
alter table books enable row level security;
alter table verses enable row level security;
alter table user_progress enable row level security;
alter table favorites enable row level security;
alter table badges enable row level security;
alter table user_badges enable row level security;
alter table settings enable row level security;

-- ================================================
-- 11. RLS Policies - Public Data
-- ================================================
-- Books, verses, and badges are public (viewable by everyone)
create policy "Books are viewable by everyone"
  on books for select
  using (true);

create policy "Verses are viewable by everyone"
  on verses for select
  using (true);

create policy "Badges are viewable by everyone"
  on badges for select
  using (true);

-- ================================================
-- 12. RLS Policies - User Progress
-- ================================================
create policy "Users can view own progress"
  on user_progress for select
  using (auth.uid() = user_id);

create policy "Users can insert own progress"
  on user_progress for insert
  with check (auth.uid() = user_id);

create policy "Users can update own progress"
  on user_progress for update
  using (auth.uid() = user_id);

-- ================================================
-- 13. RLS Policies - Favorites
-- ================================================
create policy "Users can view own favorites"
  on favorites for select
  using (auth.uid() = user_id);

create policy "Users can manage own favorites"
  on favorites for all
  using (auth.uid() = user_id);

-- ================================================
-- 14. RLS Policies - User Badges
-- ================================================
create policy "Users can view own badges"
  on user_badges for select
  using (auth.uid() = user_id);

create policy "Users can unlock badges"
  on user_badges for insert
  with check (auth.uid() = user_id);

-- ================================================
-- 15. RLS Policies - Settings
-- ================================================
create policy "Users can view own settings"
  on settings for select
  using (auth.uid() = user_id);

create policy "Users can manage own settings"
  on settings for all
  using (auth.uid() = user_id);

-- ================================================
-- 16. Sample Data - Badges
-- ================================================
-- Insert sample badges for the app
insert into badges (id, name_ar, description_ar, icon_key, condition_type, condition_value) values
  ('first_game', 'أول لعبة', 'أكمل أول لعبة', 'stars', 'games_played', 1),
  ('verse_master_10', 'حافظ الآيات', 'احفظ 10 آيات', 'book', 'verses_completed', 10),
  ('verse_master_50', 'نجم الحفظ', 'احفظ 50 آية', 'star', 'verses_completed', 50),
  ('verse_master_100', 'خبير الحفظ', 'احفظ 100 آية', 'diamond', 'verses_completed', 100),
  ('score_100', 'جامع النقاط', 'احصل على 100 نقطة', 'trophy', 'total_score', 100),
  ('score_500', 'بطل النقاط', 'احصل على 500 نقطة', 'medal', 'total_score', 500),
  ('score_1000', 'أسطورة النقاط', 'احصل على 1000 نقطة', 'crown', 'total_score', 1000),
  ('games_10', 'لاعب نشط', 'العب 10 ألعاب', 'gamepad', 'games_played', 10),
  ('games_50', 'لاعب محترف', 'العب 50 لعبة', 'controller', 'games_played', 50),
  ('level_5', 'المستوى 5', 'وصل للمستوى 5', 'level', 'current_level', 5),
  ('level_10', 'المستوى 10', 'وصل للمستوى 10', 'level_up', 'current_level', 10)
on conflict (id) do nothing;

-- ================================================
-- 17. Sample Data - Books (New Testament Examples)
-- ================================================
-- Insert some sample books
insert into books (numeric_id, name_ar, chapters_count) values
  (50, 'إنجيل متى', 28),
  (51, 'إنجيل مرقس', 16),
  (52, 'إنجيل لوقا', 24),
  (53, 'إنجيل يوحنا', 21),
  (54, 'سفر أعمال الرسل', 28),
  (55, 'رسالة بولس الرسول إلى أهل رومية', 16),
  (56, 'رسالة بولس الرسول الأولى إلى أهل كورنثوس', 16),
  (57, 'رسالة بولس الرسول الثانية إلى أهل كورنثوس', 13),
  (58, 'رسالة بولس الرسول إلى أهل غلاطية', 6),
  (59, 'رسالة بولس الرسول إلى أهل أفسس', 6),
  (60, 'رسالة بولس الرسول إلى أهل فيلبي', 4),
  (61, 'رسالة بولس الرسول إلى أهل كولوسي', 4),
  (62, 'رسالة بولس الرسول الأولى إلى أهل تسالونيكي', 5),
  (63, 'رسالة بولس الرسول الثانية إلى أهل تسالونيكي', 3),
  (64, 'رسالة بولس الرسول الأولى إلى تيموثاوس', 6),
  (65, 'رسالة بولس الرسول الثانية إلى تيموثاوس', 4),
  (66, 'رسالة بولس الرسول إلى تيطس', 3),
  (67, 'رسالة بولس الرسول إلى فليمون', 1),
  (68, 'رسالة بولس الرسول إلى العبرانيين', 13),
  (69, 'رسالة يعقوب', 5),
  (70, 'رسالة بطرس الرسول الأولى', 5),
  (71, 'رسالة بطرس الرسول الثانية', 3),
  (72, 'رسالة يوحنا الرسول الأولى', 5),
  (73, 'رسالة يوحنا الرسول الثانية', 1),
  (74, 'رسالة يوحنا الرسول الثالثة', 1),
  (75, 'رسالة يهوذا', 1),
  (76, 'سفر رؤيا يوحنا اللاهوتي', 22)
on conflict (numeric_id) do nothing;

-- ================================================
-- 18. Sample Data - Verses (The Beatitudes - Matthew 5:3-12)
-- ================================================
-- Insert some sample verses from the Sermon on the Mount
insert into verses (ref, book_id, book_name, chapter, verse_number, text_ar) values
  ('50-5-3', 50, 'إنجيل متى', 5, 3, 'طُوبَى لِلْمَسَاكِينِ بِالرُّوحِ، لأَنَّ لَهُمْ مَلَكُوتَ السَّمَاوَاتِ.'),
  ('50-5-4', 50, 'إنجيل متى', 5, 4, 'طُوبَى لِلْحَزَانَى، لأَنَّهُمْ يَتَعَزَّوْنَ.'),
  ('50-5-5', 50, 'إنجيل متى', 5, 5, 'طُوبَى لِلْوُدَعَاءِ، لأَنَّهُمْ يَرِثُونَ الأَرْضَ.'),
  ('50-5-6', 50, 'إنجيل متى', 5, 6, 'طُوبَى لِلْجِيَاعِ وَالْعِطَاشِ إِلَى الْبِرِّ، لأَنَّهُمْ يُشْبَعُونَ.'),
  ('50-5-7', 50, 'إنجيل متى', 5, 7, 'طُوبَى لِلرُّحَمَاءِ، لأَنَّهُمْ يُرْحَمُونَ.'),
  ('50-5-8', 50, 'إنجيل متى', 5, 8, 'طُوبَى لِلأَنْقِيَاءِ الْقَلْبِ، لأَنَّهُمْ يُعَايِنُونَ اللهَ.'),
  ('50-5-9', 50, 'إنجيل متى', 5, 9, 'طُوبَى لِصَانِعِي السَّلاَمِ، لأَنَّهُمْ أَبْنَاءَ اللهِ يُدْعَوْنَ.'),
  ('50-5-10', 50, 'إنجيل متى', 5, 10, 'طُوبَى لِلْمَطْرُودِينَ مِنْ أَجْلِ الْبِرِّ، لأَنَّ لَهُمْ مَلَكُوتَ السَّمَاوَاتِ.'),
  ('50-5-11', 50, 'إنجيل متى', 5, 11, 'طُوبَى لَكُمْ إِذَا عَيَّرُوكُمْ وَطَرَدُوكُمْ وَقَالُوا عَلَيْكُمْ كُلَّ كَلِمَةٍ شِرِّيرَةٍ، مِنْ أَجْلِي، كَاذِبِينَ.'),
  ('50-5-12', 50, 'إنجيل متى', 5, 12, 'اِفْرَحُوا وَتَهَلَّلُوا، لأَنَّ أَجْرَكُمْ عَظِيمٌ فِي السَّمَاوَاتِ، فَإِنَّهُمْ هكَذَا طَرَدُوا الأَنْبِيَاءَ الَّذِينَ قَبْلَكُمْ.')
on conflict (ref) do nothing;

-- ================================================
-- 19. Functions (Optional)
-- ================================================
-- Function to automatically update the updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Triggers to update updated_at
create trigger update_user_progress_updated_at
  before update on user_progress
  for each row
  execute function update_updated_at_column();

create trigger update_settings_updated_at
  before update on settings
  for each row
  execute function update_updated_at_column();

-- ================================================
-- 20. Useful Queries
-- ================================================

-- Get user statistics
-- select 
--   user_id,
--   total_verses_completed,
--   total_games_played,
--   total_score,
--   current_level
-- from user_progress
-- where user_id = 'YOUR_USER_ID';

-- Get user's unlocked badges
-- select 
--   b.name_ar,
--   b.description_ar,
--   ub.unlocked_at
-- from user_badges ub
-- join badges b on ub.badge_id = b.id
-- where ub.user_id = 'YOUR_USER_ID'
-- order by ub.unlocked_at desc;

-- Get favorite verses with full text
-- select 
--   v.ref,
--   v.book_name,
--   v.chapter,
--   v.verse_number,
--   v.text_ar
-- from favorites f
-- join verses v on f.verse_ref = v.ref
-- where f.user_id = 'YOUR_USER_ID'
-- order by f.created_at desc;

-- ================================================
-- End of Schema
-- ================================================
