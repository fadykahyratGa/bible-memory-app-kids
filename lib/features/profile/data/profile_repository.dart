import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';

import 'package:bible_memory_app_kids/features/profile/domain/player_profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _clientOrThrow => _client ?? (throw const AppException(code: 'missing_config', userMessage: AppErrorMapper.missingConfigMessage));

  Future<PlayerProfile?> fetchOwnProfile(String userId) async {
    final result = await _clientOrThrow.from('profiles').select().eq('id', userId).maybeSingle();
    if (result == null) {
      return null;
    }
    return PlayerProfile.fromMap(result);
  }

  Future<PlayerProfile> upsertOwnProfile({
    required String userId,
    required String displayName,
    String? avatarId,
  }) async {
    final payload = <String, dynamic>{
      'id': userId,
      'display_name': displayName,
      'avatar_id': avatarId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final result = await _clientOrThrow.from('profiles').upsert(payload).select().single();
    return PlayerProfile.fromMap(result);
  }
}
