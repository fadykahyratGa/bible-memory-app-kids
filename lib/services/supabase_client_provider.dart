import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/config/app_config.dart';
import 'package:bible_memory_app_kids/core/logging/app_logger.dart';

class SupabaseClientProvider {
  SupabaseClientProvider._();

  static bool _isInitialized = false;
  static AppConfig _config = const AppConfig(supabaseUrl: '', supabaseAnonKey: '');

  static bool get isConfigured => _config.isConfigured;

  static Future<void> initialize([AppConfig? config]) async {
    _config = config ?? AppConfig.fromEnvironment();
    if (_isInitialized || !_config.isConfigured) {
      if (!_config.isConfigured) {
        AppLogger.warning('supabase.init.skipped_missing_config');
      }
      return;
    }

    await Supabase.initialize(url: _config.supabaseUrl, anonKey: _config.supabaseAnonKey);
    _isInitialized = true;
    AppLogger.info('supabase.init.complete');
  }

  static SupabaseClient? get maybeClient => _isInitialized ? Supabase.instance.client : null;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<String?> ensureUser() async {
    if (!isConfigured) {
      return null;
    }
    final auth = client.auth;
    if (auth.currentUser != null) return auth.currentUser!.id;
    try {
      final response = await auth.signInAnonymously();
      return response.user?.id;
    } on AuthException catch (error) {
      debugPrint('Supabase auth error: ${error.message}');
      return null;
    } catch (error) {
      debugPrint('Unexpected Supabase error: $error');
      return null;
    }
  }
}
