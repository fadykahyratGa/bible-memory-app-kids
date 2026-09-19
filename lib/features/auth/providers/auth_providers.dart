import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/logging/app_logger.dart';
import 'package:bible_memory_app_kids/features/auth/data/auth_repository.dart';
import 'package:bible_memory_app_kids/features/profile/data/profile_repository.dart';
import 'package:bible_memory_app_kids/features/profile/domain/player_profile.dart';
import 'package:bible_memory_app_kids/features/rooms/data/room_repository.dart';
import 'package:bible_memory_app_kids/services/supabase_client_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) => SupabaseClientProvider.maybeClient);
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseClientProvider)));
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(supabaseClientProvider)));
final roomRepositoryProvider = Provider<RoomRepository>((ref) => RoomRepository(ref.watch(supabaseClientProvider)));

class AppSessionController extends ChangeNotifier {
  AppSessionController({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required RoomRepository roomRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        _roomRepository = roomRepository;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final RoomRepository _roomRepository;

  bool _isLoading = true;
  AppException? _error;
  PlayerProfile? _profile;
  User? _user;
  String? _restoreLocation;

  bool get isLoading => _isLoading;
  AppException? get error => _error;
  PlayerProfile? get profile => _profile;
  User? get user => _user;
  bool get needsProfile => _user != null && _profile == null;
  String? get restoreLocation => _restoreLocation;

  Future<void> bootstrap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authRepository.restoreOrCreateAnonymousUser();
      _profile = await _profileRepository.fetchOwnProfile(_user!.id);
      if (_profile != null) {
        final membership = await _roomRepository.findActiveMembership();
        _restoreLocation = membership?.restoreLocation;
      } else {
        _restoreLocation = null;
      }
      AppLogger.info('app.bootstrap.complete', <String, Object?>{
        'userId': _user?.id,
        'hasProfile': _profile != null,
        'restoreLocation': _restoreLocation,
      });
    } catch (error, stackTrace) {
      _user = null;
      _profile = null;
      _restoreLocation = null;
      AppLogger.error('app.bootstrap.failed', error, <String, Object?>{'stackTrace': '$stackTrace'});
      _error = AppErrorMapper.map(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(String displayName) async {
    if (_user == null) {
      throw const AppException(code: 'missing_user', userMessage: AppErrorMapper.connectionProblemMessage);
    }
    _profile = await _profileRepository.upsertOwnProfile(userId: _user!.id, displayName: displayName.trim());
    _restoreLocation ??= '/home';
    notifyListeners();
  }

  Future<void> refreshProfileAndMembership() async {
    _restoreLocation = null;
    if (_user == null) {
      await bootstrap();
      return;
    }

    try {
      _profile = await _profileRepository.fetchOwnProfile(_user!.id);
      final membership = _profile == null ? null : await _roomRepository.findActiveMembership();
      _restoreLocation = membership?.restoreLocation;
      notifyListeners();
    } catch (_) {
      _restoreLocation = null;
      notifyListeners();
      rethrow;
    }
  }

  void clearRestoreLocation() {
    _restoreLocation = null;
    notifyListeners();
  }
}

final sessionControllerProvider = ChangeNotifierProvider<AppSessionController>((ref) {
  final controller = AppSessionController(
    authRepository: ref.watch(authRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    roomRepository: ref.watch(roomRepositoryProvider),
  );
  unawaited(controller.bootstrap());
  return controller;
});
