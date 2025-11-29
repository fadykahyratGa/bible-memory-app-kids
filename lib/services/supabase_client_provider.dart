import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  static const _supabaseUrl = 'https://your-project-id.supabase.co';
  static const _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<String?> ensureUser() async {
    final auth = client.auth;
    if (auth.currentUser != null) return auth.currentUser!.id;
    try {
      final response = await auth.signInAnonymously();
      return response.user?.id;
    } on AuthException catch (e) {
      debugPrint('Supabase auth error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected Supabase error: $e');
      return null;
    }
  }
}

/*
-- Example SQL to configure Supabase schema
create table if not exists users (
  id uuid primary key references auth.users on delete cascade,
  created_at timestamptz default now()
);

create table if not exists user_progress (
  user_id uuid primary key references users(id) on delete cascade,
  total_verses_completed int default 0,
  total_games_played int default 0,
  total_score int default 0,
  current_level int default 1,
  last_game_config jsonb
);

create table if not exists favorites (
  user_id uuid references users(id) on delete cascade,
  verse_ref text not null,
  primary key (user_id, verse_ref)
);

create table if not exists badges (
  id text primary key,
  name_ar text not null,
  description_ar text not null,
  icon_key text,
  condition_type text,
  condition_value int
);

create table if not exists user_badges (
  user_id uuid references users(id) on delete cascade,
  badge_id text references badges(id) on delete cascade,
  unlocked_at timestamptz default now(),
  primary key (user_id, badge_id)
);

create table if not exists settings (
  user_id uuid primary key references users(id) on delete cascade,
  default_difficulty text default 'easy',
  sound_enabled bool default true
);
*/
