import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_client_provider.dart';

class AuthRepository {
  final GoTrueClient _auth = SupabaseClientProvider.client.auth;

  Stream<AuthState> authStateChanges() => SupabaseClientProvider.authStateChanges;

  User? get currentUser => SupabaseClientProvider.currentUser;

  Future<AuthResponse> signInAnonymously() => _auth.signInAnonymously();

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: displayName == null ? null : {'display_name': displayName},
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _auth.signOut();
}
