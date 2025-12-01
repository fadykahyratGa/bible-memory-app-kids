# Quick Setup Guide

This guide will help you get the Bible Memory App for Kids up and running quickly.

## Prerequisites

- Flutter SDK >=3.3.0 installed ([Get Flutter](https://flutter.dev/docs/get-started/install))
- A Supabase account (free tier is sufficient)
- An Android emulator, iOS simulator, or physical device

## Setup Steps

### 1. Install Flutter Dependencies

```bash
cd bible-memory-app-kids
flutter pub get
```

### 2. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in project details and wait for provisioning
4. Navigate to Project Settings > API
5. Copy your Project URL and anon/public key

### 3. Configure Supabase in the App

Edit `lib/services/supabase_client_provider.dart`:

```dart
static const _supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const _supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

### 4. Set Up Database Schema

1. In Supabase dashboard, go to SQL Editor
2. Copy the contents of `supabase_schema.sql`
3. Paste into SQL Editor and run
4. Verify tables are created in Table Editor

### 5. Run the App

```bash
# Check connected devices
flutter devices

# Run on default device
flutter run

# Or run on specific device
flutter run -d <device_id>
```

## Verify Installation

After running the app, you should see:
- ✅ Home screen with Arabic text in RTL layout
- ✅ Stats showing Level 1, 0 verses, 0 points
- ✅ Navigation to different screens working
- ✅ No authentication errors in console

## Common Issues

### Supabase Connection Error
- Verify your URL and anon key are correct
- Check if your project is fully provisioned
- Ensure you're not behind a firewall blocking supabase.co

### RTL Not Working
- This is normal in some emulators
- Test on a physical device or update emulator settings

### Cairo Font Not Loading
- Run `flutter clean` and `flutter pub get`
- Ensure you have internet connection (fonts are downloaded)

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Testing with Sample Data

The schema includes sample data:
- 27 New Testament books
- 10 sample verses from Matthew 5 (The Beatitudes)
- 11 achievement badges

You can test the game immediately with Matthew 5:3-12.

## Data Sources

The app supports two data sources:

1. **Supabase (Primary)**: Use BibleRepository for data stored in your Supabase database
2. **External API (Fallback)**: ArabicBibleApiService connects to arabic-bible.onrender.com

Initially, use the external API since your Supabase database will be empty. To populate Supabase:

1. Run the sample data inserts from `supabase_schema.sql`
2. Or write a data import script to fetch from the API and store in Supabase

## Next Steps

1. Add more Bible verses to your Supabase database
2. Customize badge conditions and rewards
3. Test the complete game flow
4. Build for production (see README.md)

## Support

For detailed documentation, see [README.md](README.md)

For issues, check the [GitHub Issues](https://github.com/fadykahyratGa/bible-memory-app-kids/issues)
