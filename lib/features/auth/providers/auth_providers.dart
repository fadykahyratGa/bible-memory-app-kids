import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../models/auth_view_state.dart';
import '../models/profile_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthController extends StateNotifier<AuthViewState> {
  AuthController(this._authRepository, this._profileRepository)
      : super(AuthViewState.signedOut()) {
    _subscription = _authRepository.authStateChanges().listen(_handleAuthChange);
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _bootstrapCurrentUser(currentUser);
    }
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<AuthState>? _subscription;

  Future<void> _bootstrapCurrentUser(User user) async {
    final profile = await _profileRepository.fetchCurrentProfile();
    state = state.copyWith(user: user, profile: profile, isLoading: false, clearError: true);
  }

  Future<void> _handleAuthChange(AuthState authState) async {
    final user = authState.session?.user;
    if (user == null) {
      state = AuthViewState.signedOut();
      return;
    }
    await _bootstrapCurrentUser(user);
  }

  Future<void> continueAsGuest(String displayName) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final response = await _authRepository.signInAnonymously();
      final user = response.user;
      if (user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'تعذر تسجيل الدخول كضيف.');
        return;
      }
      final profile = await _profileRepository.upsertProfile(displayName: displayName, isGuest: true);
      state = state.copyWith(user: user, profile: profile, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'حدث خطأ أثناء الدخول كضيف.');
    }
  }

  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      final user = response.user;
      if (user != null) {
        final profile = await _profileRepository.upsertProfile(displayName: displayName, isGuest: false);
        state = state.copyWith(
          user: user,
          profile: profile,
          isLoading: false,
          infoMessage: response.session == null ? 'تم إنشاء الحساب. تحقق من بريدك الإلكتروني للتأكيد.' : null,
          clearError: true,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        infoMessage: 'تم إنشاء الحساب. أكمل التحقق من البريد الإلكتروني.',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'تعذر إنشاء الحساب.');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final response = await _authRepository.signInWithPassword(email: email, password: password);
      final user = response.user;
      final profile = await _profileRepository.fetchCurrentProfile();
      state = state.copyWith(user: user, profile: profile, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.');
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, infoMessage: 'تم إرسال رابط إعادة تعيين كلمة المرور.');
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'تعذر إرسال رابط إعادة التعيين.');
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      await _authRepository.signOut();
      state = AuthViewState.signedOut();
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'تعذر تسجيل الخروج.');
    }
  }

  Future<ProfileModel?> refreshProfile() async {
    final profile = await _profileRepository.fetchCurrentProfile();
    state = state.copyWith(profile: profile);
    return profile;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthViewState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  );
});
