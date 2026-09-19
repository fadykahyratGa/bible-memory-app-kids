import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/logging/app_logger.dart';
import 'package:bible_memory_app_kids/services/supabase_client_provider.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient? _client;

  User? get currentUser => _client?.auth.currentUser;

  Future<User> restoreOrCreateAnonymousUser() async {
    if (!SupabaseClientProvider.isConfigured) {
      throw const AppException(code: 'missing_config', userMessage: AppErrorMapper.missingConfigMessage);
    }

    final client = _client;
    if (client == null) {
      throw const AppException(code: 'missing_config', userMessage: AppErrorMapper.missingConfigMessage);
    }

    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      AppLogger.info('auth.session.restored', <String, Object?>{'userId': currentUser.id});
      return currentUser;
    }

    AppLogger.info('auth.session.create_anonymous');
    final response = await client.auth.signInAnonymously();
    if (response.user == null) {
      throw const AppException(code: 'anonymous_auth_failed', userMessage: AppErrorMapper.connectionProblemMessage);
    }

    AppLogger.info('auth.session.created', <String, Object?>{'userId': response.user!.id});
    return response.user!;
  }
}
