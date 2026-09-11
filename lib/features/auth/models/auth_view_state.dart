import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

class AuthViewState {
  const AuthViewState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  final User? user;
  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => user != null;
  bool get isGuest => profile?.isGuest ?? false;

  AuthViewState copyWith({
    User? user,
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthViewState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }

  factory AuthViewState.signedOut() => const AuthViewState();
}
