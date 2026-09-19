import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/game/data/game_repository.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) => GameRepository(ref.watch(supabaseClientProvider)));

final activeGameProvider = StreamProvider.family<GameSession?, String>((ref, roomId) {
  return ref.watch(gameRepositoryProvider).observeGame(roomId);
});

final currentChallengeProvider = StreamProvider.family<GameChallenge?, String>((ref, roomId) async* {
  final repository = ref.watch(gameRepositoryProvider);
  String? lastChallengeKey;
  GameChallenge? lastChallenge;

  await for (final game in ref.watch(activeGameProvider(roomId).stream)) {
    if (game == null) {
      lastChallengeKey = null;
      lastChallenge = null;
      yield null;
      continue;
    }

    final challengeKey = '${game.id}:${game.currentRoundOrder}:${game.currentChallengeOrder}';
    if (challengeKey == lastChallengeKey) {
      yield lastChallenge;
      continue;
    }

    lastChallengeKey = challengeKey;
    lastChallenge = await repository.fetchCurrentChallenge(roomId);
    yield lastChallenge;
  }
});
