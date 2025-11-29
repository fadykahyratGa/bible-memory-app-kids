import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_config.dart';
import 'supabase_client_provider.dart';

class SettingsService {
  SettingsService({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;

  Future<Difficulty> loadDifficulty(String userId) async {
    final result = await _client.from('settings').select('default_difficulty').eq('user_id', userId).maybeSingle();
    if (result == null) return Difficulty.easy;
    return Difficulty.values.firstWhere(
      (element) => element.name == result['default_difficulty'],
      orElse: () => Difficulty.easy,
    );
  }

  Future<bool> loadSoundEnabled(String userId) async {
    final result = await _client.from('settings').select('sound_enabled').eq('user_id', userId).maybeSingle();
    return result?['sound_enabled'] as bool? ?? true;
  }

  Future<void> saveSettings(String userId, Difficulty difficulty, bool soundEnabled) async {
    await _client.from('settings').upsert({
      'user_id': userId,
      'default_difficulty': difficulty.name,
      'sound_enabled': soundEnabled,
    });
  }
}
