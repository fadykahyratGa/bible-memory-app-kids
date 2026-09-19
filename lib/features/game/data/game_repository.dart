import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';

import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';

int _compareDescNullableString(String? left, String? right) {
  final leftHasValue = left != null && left.isNotEmpty;
  final rightHasValue = right != null && right.isNotEmpty;
  if (leftHasValue != rightHasValue) {
    return leftHasValue ? -1 : 1;
  }
  return (right ?? '').compareTo(left ?? '');
}

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
      rows.sort((a, b) {
        final startedCompare = _compareDescNullableString(a['started_at'] as String?, b['started_at'] as String?);
        if (startedCompare != 0) {
          return startedCompare;
        }

        final createdCompare = _compareDescNullableString(a['created_at'] as String?, b['created_at'] as String?);
        if (createdCompare != 0) {
          return createdCompare;
        }

        return _compareDescNullableString(a['id'] as String?, b['id'] as String?);
      });
      return GameSession.fromMap(rows.first);
    });
  }

  Future<GameChallenge?> fetchCurrentChallenge(String roomId) async {
    final response = await _clientOrThrow.rpc('get_current_challenge', params: <String, dynamic>{'p_room_id': roomId});
    if (response is! List || response.isEmpty) {
      return null;
    }

    return GameChallenge.fromMap(Map<String, dynamic>.from(response.first as Map));
  }
}
