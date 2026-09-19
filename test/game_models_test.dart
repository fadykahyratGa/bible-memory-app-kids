import 'package:flutter_test/flutter_test.dart';

import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';

void main() {
  group('game enums', () {
    test('parses game state values with underscores', () {
      expect(MultiplayerGameState.fromValue('round_results'), MultiplayerGameState.roundResults);
      expect(MultiplayerGameState.fromValue('game_results'), MultiplayerGameState.gameResults);
    });

    test('parses challenge types from database values', () {
      expect(ChallengeType.fromValue('multiple_choice'), ChallengeType.multipleChoice);
      expect(ChallengeType.fromValue('true_false'), ChallengeType.trueFalse);
    });
  });

  test('ScoreCalculator awards points only for correct answers', () {
    expect(ScoreCalculator.pointsFor(isCorrect: true, basePoints: 10), 10);
    expect(ScoreCalculator.pointsFor(isCorrect: false, basePoints: 10), 0);
  });
}
