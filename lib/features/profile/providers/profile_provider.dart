import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/profile/domain/player_profile.dart';

final currentProfileProvider = Provider<PlayerProfile?>((ref) {
  return ref.watch(sessionControllerProvider).profile;
});
