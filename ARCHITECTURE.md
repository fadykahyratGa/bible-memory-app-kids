# Architecture Documentation

## Overview

The Bible Memory App for Kids follows a clean, layered architecture pattern with clear separation of concerns. This document outlines the architectural decisions and structure.

## Design Principles

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Dependency Injection**: Services and dependencies are injected for testability
3. **State Management**: Provider pattern for reactive state updates
4. **RTL-First**: Right-to-left layout throughout the entire app
5. **Kid-Friendly**: Large touch targets, bright colors, simple navigation

## Architecture Layers

```
┌─────────────────────────────────────┐
│         UI Layer                    │
│  (Screens, Widgets, Theme)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      State Management Layer         │
│         (Providers)                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Business Logic Layer          │
│         (Services)                  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Data Layer                   │
│  (Models, Repository, API)          │
└─────────────────────────────────────┘
```

## Layer Details

### 1. UI Layer (`lib/ui/`)

Responsible for presentation and user interaction.

#### Screens (`lib/ui/screens/`)
- **HomeScreen**: Main dashboard with stats, daily verse, and navigation
- **PlayMenuScreen**: Difficulty selection interface
- **RangeSelectionScreen**: Book/chapter/verse picker
- **GameScreen**: Interactive game interface with question and options
- **ResultScreen**: Shows correct/incorrect feedback
- **BadgesScreen**: Achievement badge display
- **SettingsScreen**: User preferences configuration
- **PrayersScreen**: Prayer requests feature (future)

#### Widgets (`lib/ui/widgets/`)
Reusable UI components:
- **PrimaryButton**: Styled button with consistent appearance
- **TileButton**: Selectable option tile for game
- **AppCard**: Container with consistent card styling
- **ProgressBar**: Visual progress indicator
- **RoundedPanel**: Rounded container with shadow
- **CloudBackground**: Decorative background
- **IconBadge**: Badge display component

#### Theme (`lib/theme/`)
- **AppTheme**: Material 3 theme configuration with Cairo font
- **AppColors**: Color palette constants

**Design Decisions:**
- Material 3 for modern, accessible UI
- Cairo font for proper Arabic rendering
- Custom theme to match kid-friendly aesthetics
- Reusable widgets to maintain consistency

### 2. State Management Layer (`lib/providers/`)

Uses Provider pattern (ChangeNotifier) for reactive state.

#### GameProvider
- Manages game state (current question, score, progress)
- Handles user answers and validation
- Coordinates with GameEngine and ArabicBibleApiService

**State:**
```dart
- GameState? _state
- List<String> _currentAnswer
```

**Key Methods:**
```dart
- startGame(GameConfig) → Future<void>
- addAnswer(String) → void
- removeAnswer(String) → void
- checkAnswer() → bool
- nextQuestion() → bool
```

#### ProgressProvider
- Tracks user progress (verses completed, games played, score)
- Manages favorites
- Syncs with Supabase via ProgressService

**State:**
```dart
- UserProgress _progress
- List<String> _favorites
```

**Key Methods:**
```dart
- load() → Future<void>
- recordResult({bool correct, GameConfig config, int score}) → Future<void>
- toggleFavorite(String verseRef) → Future<void>
```

#### SettingsProvider
- Manages user settings (difficulty, sound)
- Persists to Supabase via SettingsService

**State:**
```dart
- Difficulty _difficulty
- bool _soundEnabled
```

**Key Methods:**
```dart
- load() → Future<void>
- save(Difficulty difficulty, bool soundEnabled) → Future<void>
```

**Design Decisions:**
- Provider chosen for simplicity and framework support
- Each provider handles one concern
- Async operations with proper loading states

### 3. Business Logic Layer (`lib/services/`)

Contains core business logic and external integrations.

#### BibleRepository
Primary data access for Bible content stored in Supabase.

**Responsibilities:**
- Fetch books from Supabase
- Fetch verses by book/chapter/range
- Search verses

**Key Methods:**
```dart
- fetchBooks() → Future<List<Book>>
- fetchBook(int bookId) → Future<Book?>
- fetchChapterVerses({int bookId, int chapter}) → Future<List<Verse>>
- fetchVerseRange({int bookId, int chapter, int fromVerse, int toVerse}) → Future<List<Verse>>
- fetchVerseByRef(String ref) → Future<Verse?>
- searchVerses(String query) → Future<List<Verse>>
```

#### ArabicBibleApiService
Fallback data source using external API (arabic-bible.onrender.com).

**Responsibilities:**
- Fetch books from external API
- Fetch verses from external API
- Provide fallback when Supabase is empty

**Key Methods:**
```dart
- fetchBooks() → Future<List<Book>>
- fetchChaptersInfo() → Future<Map<int, int>>
- fetchBookChapterCount(int bookId) → Future<int?>
- fetchChapterVerses({int bookId, int chapter}) → Future<List<String>>
- fetchVerseRange({int bookId, String bookName, int chapter, int from, int to}) → Future<List<Verse>>
```

#### GameEngine
Pure business logic for game mechanics.

**Responsibilities:**
- Generate questions from verses
- Validate answers
- Calculate scores

**Key Methods:**
```dart
- buildQuestions(List<Verse> verses, Difficulty difficulty) → List<Question>
- isAnswerCorrect(Question question, List<String> userAnswer) → bool
- calculateScore({Difficulty difficulty, bool correct}) → int
```

**Game Logic:**
- Easy: Hide ~1/6 of words
- Medium: Hide ~1/5 of words
- Hard: Hide ~1/4 of words
- Scores: Easy=5, Medium=10, Hard=15 points

#### ProgressService
Manages user progress data in Supabase.

**Responsibilities:**
- Load/save user progress
- Manage favorites
- Track statistics

**Key Methods:**
```dart
- loadProgress(String userId) → Future<UserProgress>
- upsertProgress(String userId, UserProgress progress) → Future<void>
- fetchFavorites(String userId) → Future<List<String>>
- toggleFavorite(String userId, String verseRef, bool isFavorite) → Future<void>
```

#### SettingsService
Manages user settings in Supabase.

**Responsibilities:**
- Load/save user preferences
- Default difficulty
- Sound settings

**Key Methods:**
```dart
- loadDifficulty(String userId) → Future<Difficulty>
- loadSoundEnabled(String userId) → Future<bool>
- saveSettings(String userId, Difficulty difficulty, bool soundEnabled) → Future<void>
```

#### SupabaseClientProvider
Singleton for Supabase client management.

**Responsibilities:**
- Initialize Supabase
- Provide client instance
- Handle anonymous authentication

**Key Methods:**
```dart
- initialize() → Future<void>
- get client → SupabaseClient
- ensureUser() → Future<String?>
```

**Design Decisions:**
- Services are stateless and injectable
- Each service has a single responsibility
- Async/await for all I/O operations
- Graceful error handling with fallbacks

### 4. Data Layer (`lib/models/`)

Immutable data classes representing domain entities.

#### Models

**Book**
```dart
{
  String id,
  String nameAr,
  int chaptersCount,
  int numericId
}
```

**Verse**
```dart
{
  String ref,              // "bookId-chapter-verse"
  String bookId,
  String bookName,
  int chapter,
  int verseNumber,
  String textAr
}
```

**GameConfig**
```dart
{
  int book,
  String bookName,
  int chapter,
  int fromVerse,
  int toVerse,
  Difficulty difficulty
}
```
- Serializable to/from JSON for persistence

**Question**
```dart
{
  Verse verse,
  List<String> hiddenWords,
  List<String> options,
  String maskedText
}
```

**GameState**
```dart
{
  GameConfig config,
  List<Question> questions,
  int currentIndex,
  int score,
  int correctCount,
  int wrongCount,
  GameStatus status
}
```
- Immutable with copyWith method

**Badge**
```dart
{
  String id,
  String nameAr,
  String descriptionAr,
  String iconKey,
  String conditionType,
  int conditionValue
}
```

**UserProgress**
```dart
{
  int totalVersesCompleted,
  int totalGamesPlayed,
  int totalScore,
  int currentLevel,
  GameConfig? lastGameConfig
}
```

**Enums:**
- **Difficulty**: easy, medium, hard
- **GameStatus**: inProgress, completed

**Design Decisions:**
- Immutable data classes
- Clear, descriptive property names
- JSON serialization where needed
- Const constructors for performance

## Data Flow

### Game Flow
```
1. User selects difficulty → PlayMenuScreen
2. User selects verses → RangeSelectionScreen
3. GameProvider.startGame(config)
   ├─ ArabicBibleApiService.fetchVerseRange()
   └─ GameEngine.buildQuestions()
4. GameScreen displays question
5. User selects answers
6. User confirms → GameProvider.checkAnswer()
   ├─ GameEngine.isAnswerCorrect()
   ├─ GameEngine.calculateScore()
   └─ ProgressProvider.recordResult()
7. ResultScreen shows feedback
8. GameProvider.nextQuestion() or complete
```

### Progress Sync Flow
```
1. App launches → main.dart
2. SupabaseClientProvider.initialize()
3. SupabaseClientProvider.ensureUser() (anonymous auth)
4. ProgressProvider.load()
   └─ ProgressService.loadProgress(userId)
5. SettingsProvider.load()
   └─ SettingsService.loadDifficulty/loadSoundEnabled(userId)
6. HomeScreen displays user data
```

### Data Source Priority
```
1. Check Supabase database (BibleRepository)
2. If empty, use External API (ArabicBibleApiService)
3. If API fails, use fallback data
```

## Authentication Strategy

**Anonymous Authentication:**
- No email/password required
- Automatic user creation on first launch
- User ID persists in local storage
- Can upgrade to full auth later

**Benefits:**
- Frictionless onboarding for kids
- Still allows progress tracking
- Can migrate to full auth when needed

**Implementation:**
```dart
// In SupabaseClientProvider
static Future<String?> ensureUser() async {
  if (auth.currentUser != null) return auth.currentUser!.id;
  final response = await auth.signInAnonymously();
  return response.user?.id;
}
```

## Database Schema

See `supabase_schema.sql` for complete schema.

**Tables:**
- `users`: User records
- `books`: Bible books
- `verses`: Bible verses
- `user_progress`: Progress tracking
- `favorites`: Favorite verses
- `badges`: Achievement definitions
- `user_badges`: Unlocked badges
- `settings`: User preferences

**Security:**
- Row Level Security (RLS) enabled
- Public read for books/verses/badges
- User-specific read/write for personal data

## Navigation

**Pattern:** Named routes with MaterialPageRoute

**Navigation Tree:**
```
HomeScreen (root)
├─ PlayMenuScreen
│  └─ RangeSelectionScreen
│     └─ GameScreen
│        └─ ResultScreen → (back to GameScreen or HomeScreen)
├─ RangeSelectionScreen (direct)
├─ BadgesScreen
├─ SettingsScreen
└─ PrayersScreen
```

**Data Passing:**
- Via constructor parameters
- Via Provider for global state
- Via Navigator arguments for screen-specific data

## Localization & RTL

**Strategy:**
- Hardcoded Arabic strings (single language app)
- flutter_localizations for RTL support
- Directionality widget at app root

**RTL Layout:**
```dart
// In app.dart
Directionality(
  textDirection: TextDirection.rtl,
  child: HomeScreen(),
)
```

**Font:**
- Google Fonts Cairo for proper Arabic rendering
- Loaded dynamically on first use
- Fallback to system font if unavailable

## Performance Considerations

1. **Lazy Loading**: Providers load data on demand
2. **Caching**: Supabase client caches responses
3. **Pagination**: Ready for large datasets (not yet implemented)
4. **Image Optimization**: Minimal images, use Icons
5. **Build Optimization**: Const constructors where possible

## Error Handling

**Strategy:**
- Graceful degradation
- Fallback data sources
- User-friendly error messages
- Debug logging for development

**Examples:**
```dart
// In BibleRepository
try {
  final response = await _client.from('books').select();
  return parseBooks(response);
} catch (e) {
  return []; // Return empty list, don't crash
}

// In ArabicBibleApiService
final response = await _safeGet(uri);
if (response == null) return fallbackData;
```

## Testing Strategy

**Unit Tests:**
- Models: JSON serialization
- Services: Business logic (GameEngine)
- Providers: State transitions

**Widget Tests:**
- Widgets: Rendering and interaction
- Screens: Navigation and layout

**Integration Tests:**
- Full game flow
- Supabase integration
- API fallback

## Future Enhancements

1. **Offline Mode**: Cache verses locally
2. **Leaderboards**: Compare with friends
3. **Voice Recording**: Practice pronunciation
4. **Daily Challenges**: Scheduled content
5. **Parent Dashboard**: Track child progress
6. **Multi-language**: Support other languages
7. **Animations**: More engaging feedback
8. **Sound Effects**: Audio feedback for actions

## Dependencies

**Production:**
- `flutter`: Framework
- `flutter_localizations`: RTL support
- `provider`: State management
- `supabase_flutter`: Backend services
- `google_fonts`: Cairo font
- `http`: External API calls
- `intl`: Internationalization

**Development:**
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality

## Build Configuration

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 33 (Android 13)
- RTL support enabled

**iOS:**
- Minimum iOS: 12.0
- RTL support enabled

## Deployment

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
# Then use Xcode for signing and upload
```

## Conclusion

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Testable components
- ✅ Scalable structure
- ✅ Maintainable codebase
- ✅ Kid-friendly UX
- ✅ Production-ready quality

The layered approach allows for easy feature additions and modifications without affecting other parts of the system.
