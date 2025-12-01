# Bible Memory App for Kids - احفظ كلمة الله

A production-ready Flutter 3 application for children to memorize Bible verses in Arabic with RTL support and a fun "Complete the verse" game. Built with Supabase for backend services.

## 🌟 Features

- **Arabic RTL Interface**: Full right-to-left layout with Cairo font
- **Complete the Verse Game**: Interactive game with three difficulty levels
- **Progress Tracking**: Track completed verses, games played, and scores
- **Badge System**: Earn badges for achievements
- **Favorites**: Save favorite verses
- **Anonymous Authentication**: Easy signup with Supabase anonymous auth
- **Kid-Friendly Design**: Bright colors, large buttons, and engaging UI
- **Offline Support**: Local caching with shared_preferences

## 📋 Requirements

- Flutter SDK: >=3.3.0 <4.0.0
- Dart SDK: >=3.0.0
- Supabase account (free tier works)

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root widget with RTL support
├── models/                   # Data models
│   ├── book.dart
│   ├── verse.dart
│   ├── game_config.dart
│   ├── question.dart
│   ├── game_state.dart
│   ├── badge.dart
│   └── user_progress.dart
├── services/                 # Business logic layer
│   ├── bible_repository.dart         # Supabase Bible data access
│   ├── arabic_bible_api_service.dart # External API fallback
│   ├── game_engine.dart              # Game logic
│   ├── progress_service.dart         # Progress tracking
│   ├── settings_service.dart         # User settings
│   └── supabase_client_provider.dart # Supabase client
├── providers/                # State management (Provider pattern)
│   ├── game_provider.dart
│   ├── progress_provider.dart
│   └── settings_provider.dart
├── ui/
│   ├── screens/              # Application screens
│   │   ├── home_screen.dart
│   │   ├── range_selection_screen.dart
│   │   ├── game_screen.dart
│   │   ├── result_screen.dart
│   │   ├── badges_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── play_menu_screen.dart
│   │   └── prayers_screen.dart
│   └── widgets/              # Reusable UI components
│       ├── primary_button.dart
│       ├── tile_button.dart
│       ├── app_card.dart
│       ├── progress_bar.dart
│       ├── rounded_panel.dart
│       ├── cloud_background.dart
│       └── icon_badge.dart
└── theme/                    # Theme and styling
    ├── app_theme.dart
    └── app_colors.dart
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/fadykahyratGa/bible-memory-app-kids.git
cd bible-memory-app-kids
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

#### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the database to be provisioned
3. Note your project URL and anon key from Settings > API

#### Set up the Database Schema

Run the following SQL in the Supabase SQL Editor:

```sql
-- Enable Row Level Security
alter database postgres set "app.jwt_secret" to 'your-jwt-secret';

-- Users table (automatically created by Supabase Auth)
-- We just create a reference table
create table if not exists public.users (
  id uuid primary key references auth.users on delete cascade,
  created_at timestamptz default now()
);

-- Books table
create table if not exists public.books (
  id serial primary key,
  numeric_id int unique not null,
  name_ar text not null,
  chapters_count int not null,
  created_at timestamptz default now()
);

-- Verses table
create table if not exists public.verses (
  id serial primary key,
  ref text unique not null,
  book_id int not null,
  book_name text not null,
  chapter int not null,
  verse_number int not null,
  text_ar text not null,
  created_at timestamptz default now()
);

-- User progress table
create table if not exists public.user_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  total_verses_completed int default 0,
  total_games_played int default 0,
  total_score int default 0,
  current_level int default 1,
  last_game_config jsonb,
  updated_at timestamptz default now()
);

-- Favorites table
create table if not exists public.favorites (
  user_id uuid references auth.users(id) on delete cascade,
  verse_ref text not null,
  created_at timestamptz default now(),
  primary key (user_id, verse_ref)
);

-- Badges table
create table if not exists public.badges (
  id text primary key,
  name_ar text not null,
  description_ar text not null,
  icon_key text,
  condition_type text,
  condition_value int
);

-- User badges table
create table if not exists public.user_badges (
  user_id uuid references auth.users(id) on delete cascade,
  badge_id text references badges(id) on delete cascade,
  unlocked_at timestamptz default now(),
  primary key (user_id, badge_id)
);

-- Settings table
create table if not exists public.settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  default_difficulty text default 'easy',
  sound_enabled bool default true,
  updated_at timestamptz default now()
);

-- Indexes for better performance
create index if not exists idx_verses_book_chapter on verses(book_id, chapter);
create index if not exists idx_verses_ref on verses(ref);
create index if not exists idx_favorites_user on favorites(user_id);
create index if not exists idx_user_badges_user on user_badges(user_id);

-- Enable RLS
alter table books enable row level security;
alter table verses enable row level security;
alter table user_progress enable row level security;
alter table favorites enable row level security;
alter table badges enable row level security;
alter table user_badges enable row level security;
alter table settings enable row level security;

-- RLS Policies
-- Books and verses are public (readable by all)
create policy "Books are viewable by everyone"
  on books for select
  using (true);

create policy "Verses are viewable by everyone"
  on verses for select
  using (true);

create policy "Badges are viewable by everyone"
  on badges for select
  using (true);

-- User-specific data policies
create policy "Users can view own progress"
  on user_progress for select
  using (auth.uid() = user_id);

create policy "Users can update own progress"
  on user_progress for insert
  with check (auth.uid() = user_id);

create policy "Users can update own progress"
  on user_progress for update
  using (auth.uid() = user_id);

create policy "Users can view own favorites"
  on favorites for select
  using (auth.uid() = user_id);

create policy "Users can manage own favorites"
  on favorites for all
  using (auth.uid() = user_id);

create policy "Users can view own badges"
  on user_badges for select
  using (auth.uid() = user_id);

create policy "Users can unlock badges"
  on user_badges for insert
  with check (auth.uid() = user_id);

create policy "Users can view own settings"
  on settings for select
  using (auth.uid() = user_id);

create policy "Users can manage own settings"
  on settings for all
  using (auth.uid() = user_id);

-- Insert sample badges
insert into badges (id, name_ar, description_ar, icon_key, condition_type, condition_value) values
  ('first_game', 'أول لعبة', 'أكمل أول لعبة', 'stars', 'games_played', 1),
  ('verse_master_10', 'حافظ الآيات', 'احفظ 10 آيات', 'book', 'verses_completed', 10),
  ('verse_master_50', 'نجم الحفظ', 'احفظ 50 آية', 'star', 'verses_completed', 50),
  ('score_100', 'جامع النقاط', 'احصل على 100 نقطة', 'trophy', 'total_score', 100),
  ('score_500', 'بطل النقاط', 'احصل على 500 نقطة', 'medal', 'total_score', 500)
on conflict (id) do nothing;
```

#### Configure the App

Edit `lib/services/supabase_client_provider.dart` and replace the placeholders:

```dart
static const _supabaseUrl = 'https://your-project-id.supabase.co';
static const _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Run the App

```bash
# Run on connected device or emulator
flutter run

# Or build for release
flutter build apk      # Android
flutter build ios      # iOS (requires macOS)
```

## 🎮 How to Use

1. **Home Screen**: View your progress, daily verse, and quick actions
2. **Play Menu**: Select difficulty level (Easy, Medium, Hard)
3. **Range Selection**: Choose a book, chapter, and verse range
4. **Game Screen**: Complete the verse by selecting the missing words
5. **Result Screen**: See if you got it right and continue to next verse
6. **Badges Screen**: View earned and locked badges
7. **Settings Screen**: Adjust difficulty and sound settings

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^6.1.2              # State management
  supabase_flutter: ^2.5.4      # Backend services
  google_fonts: ^6.2.1          # Cairo font for Arabic
  http: ^1.2.1                  # HTTP client for external API
  intl: ^0.20.2                 # Internationalization
```

## 🔧 Configuration Options

### Difficulty Levels

- **Easy**: ~1/6 of words hidden
- **Medium**: ~1/5 of words hidden  
- **Hard**: ~1/4 of words hidden

### Scoring System

- Easy: 5 points per correct answer
- Medium: 10 points per correct answer
- Hard: 15 points per correct answer

## 🎨 Theming

The app uses Material 3 with a custom kid-friendly theme:

- **Primary Color**: Blue (`#5E92F3`)
- **Accent Colors**: Orange, Teal, Pink, Yellow
- **Font**: Cairo (Arabic support with proper RTL)
- **Background**: Light sky blue with cloud decorations

## 🗄️ Data Models

### Difficulty Enum
```dart
enum Difficulty { easy, medium, hard }
```

### Key Models
- `Book`: Bible book information
- `Verse`: Bible verse with Arabic text
- `GameConfig`: Game configuration
- `Question`: Generated game question
- `GameState`: Current game state
- `Badge`: Achievement badge
- `UserProgress`: User progress tracking

## 🔐 Authentication

The app uses Supabase anonymous authentication, which means:
- No email/password required
- Automatic user creation on first launch
- User data persists across sessions
- Can be upgraded to full authentication later

## 🌐 Data Sources

- **Primary**: Supabase database (BibleRepository)
- **Fallback**: Arabic Bible API (ArabicBibleApiService)

## 📱 Screens Overview

1. **HomeScreen**: Main dashboard with stats and quick actions
2. **PlayMenuScreen**: Difficulty selection
3. **RangeSelectionScreen**: Book/chapter/verse selection
4. **GameScreen**: Interactive game interface
5. **ResultScreen**: Answer feedback
6. **BadgesScreen**: Achievement tracking
7. **SettingsScreen**: App configuration
8. **PrayersScreen**: Prayer requests (future feature)

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🚢 Deployment

### Android

```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# Follow Xcode signing and upload process
```

## 📝 License

This project is licensed for educational and non-commercial use.

## 🤝 Contributing

This is a demonstration project. For production use, consider:
- Adding more comprehensive error handling
- Implementing offline-first architecture
- Adding analytics and crash reporting
- Enhancing accessibility features
- Adding automated testing
- Implementing CI/CD pipeline

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

Built with ❤️ for children to learn and memorize God's Word