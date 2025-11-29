import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_config.dart';
import '../models/user_progress.dart';
import 'supabase_client_provider.dart';

class ProgressService {
  ProgressService({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;

  Future<UserProgress> loadProgress(String userId) async {
    final data = await _client.from('user_progress').select().eq('user_id', userId).maybeSingle();
    if (data == null) return UserProgress.empty();

    return UserProgress(
      totalVersesCompleted: data['total_verses_completed'] as int? ?? 0,
      totalGamesPlayed: data['total_games_played'] as int? ?? 0,
      totalScore: data['total_score'] as int? ?? 0,
      currentLevel: data['current_level'] as int? ?? 1,
      lastGameConfig: data['last_game_config'] != null
          ? GameConfig.fromJson(Map<String, dynamic>.from(data['last_game_config'] as Map))
          : null,
    );
  }

  Future<void> upsertProgress(String userId, UserProgress progress) async {
    await _client.from('user_progress').upsert({
          'user_id': userId,
          'total_verses_completed': progress.totalVersesCompleted,
          'total_games_played': progress.totalGamesPlayed,
          'total_score': progress.totalScore,
          'current_level': progress.currentLevel,
          'last_game_config': progress.lastGameConfig?.toJson(),
        });
  }

  Future<List<String>> fetchFavorites(String userId) async {
    final response = await _client.from('favorites').select('verse_ref').eq('user_id', userId);
    return (response as List<dynamic>).map((row) => row['verse_ref'] as String).toList();
  }

  Future<void> toggleFavorite(String userId, String verseRef, bool isFavorite) async {
    if (isFavorite) {
      await _client.from('favorites').delete().match({'user_id': userId, 'verse_ref': verseRef});
    } else {
      await _client.from('favorites').upsert({'user_id': userId, 'verse_ref': verseRef});
    }
  }
}
