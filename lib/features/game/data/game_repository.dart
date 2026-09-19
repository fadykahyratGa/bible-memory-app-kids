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
    await for (final game in observeGame(roomId)) {
      if (game == null) {
        yield null;
        continue;
      }

      final rounds = await _clientOrThrow
          .from('game_rounds')
          .select('id')
          .eq('game_id', game.id)
          .eq('round_order', game.currentRoundOrder)
          .limit(1);
      if (rounds is! List || rounds.isEmpty) {
        yield null;
        continue;
      }

      final roundId = (rounds.first as Map<String, dynamic>)['id'] as String;
      final challenges = await _clientOrThrow
          .from('game_challenges')
          .select()
          .eq('round_id', roundId)
          .eq('challenge_order', game.currentChallengeOrder)
          .limit(1);
      if (challenges is! List || challenges.isEmpty) {
        yield null;
        continue;
      }

      yield GameChallenge.fromMap(Map<String, dynamic>.from(challenges.first as Map));
    }
  }
}
