import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  SupabaseClientProvider._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<String?> ensureUser() async {
    final auth = client.auth;
    if (auth.currentUser != null) {
      return auth.currentUser!.id;
    }
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
