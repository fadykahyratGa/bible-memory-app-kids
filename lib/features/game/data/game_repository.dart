import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';

import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';

class GameRepository {
  GameRepository(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _clientOrThrow => _client ?? (throw const AppException(code: 'missing_config', userMessage: AppErrorMapper.missingConfigMessage));

  Future<void> startGame(String roomId) async {
    await _clientOrThrow.rpc('start_room_game', params: <String, dynamic>{'p_room_id': roomId});
  }

  Future<void> submitAnswer({required String roomId, required String challengeId, required String answer}) async {
    await _clientOrThrow.rpc(
      'submit_answer',
      params: <String, dynamic>{
        'p_room_id': roomId,
        'p_challenge_id': challengeId,
        'p_answer_text': answer,
      },
    );
  }

  Future<void> advanceChallenge(String roomId) async {
    await _clientOrThrow.rpc('advance_challenge', params: <String, dynamic>{'p_room_id': roomId});
  }

  Stream<GameSession?> observeGame(String roomId) {
    return _clientOrThrow.from('games').stream(primaryKey: <String>['id']).eq('room_id', roomId).map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      rows.sort((a, b) => (b['created_at'] as String? ?? '').compareTo(a['created_at'] as String? ?? ''));
      return GameSession.fromMap(rows.first);
    });
  }

  Stream<GameChallenge?> observeCurrentChallenge(String roomId) async* {
    String? lastKey;
    GameChallenge? lastChallenge;

    await for (final game in observeGame(roomId)) {
      if (game == null) {
        lastKey = null;
        lastChallenge = null;
        yield null;
        continue;
      }

      final currentKey = '${game.id}:${game.currentRoundOrder}:${game.currentChallengeOrder}:${game.state.name}:${game.challengeEndsAt?.millisecondsSinceEpoch ?? 0}';
      if (currentKey == lastKey) {
        yield lastChallenge;
        continue;
      }

      final response = await _clientOrThrow.rpc('get_current_challenge', params: <String, dynamic>{'p_room_id': roomId});
      if (response is! List || response.isEmpty) {
        lastKey = currentKey;
        lastChallenge = null;
        yield null;
        continue;
      }

      lastKey = currentKey;
      lastChallenge = GameChallenge.fromMap(Map<String, dynamic>.from(response.first as Map));
      yield lastChallenge;
    }
  }
}
