import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_memory_app_kids/features/game/data/game_repository.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/game/providers/game_providers.dart';

void main() {
  test('currentChallengeProvider reloads from shared game stream emissions', () async {
    final controller = StreamController<GameSession?>();
    addTearDown(controller.close);

    final repository = _FakeGameRepository(
      responses: <GameChallenge?>[
        const GameChallenge(
          id: 'challenge-1',
          roundId: 'round-1',
          challengeOrder: 1,
          type: ChallengeType.multipleChoice,
          prompt: 'Question 1',
          correctAnswer: 'A',
          points: 10,
          options: ['A', 'B'],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(repository),
        activeGameProvider('room-1').overrideWith((ref) => controller.stream),
      ],
    );
    addTearDown(container.dispose);

    final emitted = <GameChallenge?>[];
    final sub = container.listen<AsyncValue<GameChallenge?>>(
      currentChallengeProvider('room-1'),
      (previous, next) => next.whenData(emitted.add),
      fireImmediately: false,
    );
    addTearDown(sub.close);

    controller.add(const GameSession(
      id: 'game-1',
      roomId: 'room-1',
      state: MultiplayerGameState.playing,
      currentRoundOrder: 1,
      currentChallengeOrder: 1,
    ));
    await Future<void>.delayed(Duration.zero);

    controller.add(const GameSession(
      id: 'game-1',
      roomId: 'room-1',
      state: MultiplayerGameState.answering,
      currentRoundOrder: 1,
      currentChallengeOrder: 1,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(repository.fetchCalls, 1);
    expect(emitted.map((item) => item?.id).toList(), ['challenge-1', 'challenge-1']);
  });
}

class _FakeGameRepository extends GameRepository {
  _FakeGameRepository({required this.responses}) : super(null);

  final List<GameChallenge?> responses;
  int fetchCalls = 0;

  @override
  Future<GameChallenge?> fetchCurrentChallenge(String roomId) async {
    final index = fetchCalls;
    fetchCalls += 1;
    if (index >= responses.length) {
      return responses.last;
    }
    return responses[index];
  }
}
