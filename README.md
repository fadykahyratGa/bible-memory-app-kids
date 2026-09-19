# bible-memory-app-kids

## Supabase setup

Run the Flutter app with Supabase credentials provided through dart defines:

```bash
flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

The multiplayer MVP foundation also expects the SQL migration under `supabase/migrations/` to be applied before gameplay.
