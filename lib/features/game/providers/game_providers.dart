import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/game/data/game_repository.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) => GameRepository(ref.watch(supabaseClientProvider)));

final activeGameProvider = StreamProvider.family<GameSession?, String>((ref, roomId) {
  return ref.watch(gameRepositoryProvider).observeGame(roomId);
});

final currentChallengeProvider = StreamProvider.family<GameChallenge?, String>((ref, roomId) {
  return ref.watch(gameRepositoryProvider).observeCurrentChallenge(roomId);
});
