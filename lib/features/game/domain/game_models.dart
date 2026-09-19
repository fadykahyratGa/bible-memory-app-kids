enum MultiplayerGameState {
  waiting,
  starting,
  playing,
  answering,
  reviewing,
  roundResults,
  gameResults,
  paused,
  finished;

  static MultiplayerGameState fromValue(String value) {
    final normalized = value.replaceAll('_', '').toLowerCase();
    return values.firstWhere(
      (item) => item.name.toLowerCase() == normalized,
      orElse: () => MultiplayerGameState.waiting,
    );
  }
}

enum ChallengeType {
  multipleChoice,
  trueFalse;

  static ChallengeType fromValue(String value) {
    switch (value) {
      case 'multiple_choice':
        return ChallengeType.multipleChoice;
      case 'true_false':
        return ChallengeType.trueFalse;
      default:
        return values.firstWhere(
          (item) => item.name == value,
          orElse: () => ChallengeType.multipleChoice,
        );
    }
  }
}

class GameSession {
  const GameSession({
    required this.id,
    required this.roomId,
    required this.state,
    required this.currentRoundOrder,
    required this.currentChallengeOrder,
    this.startedAt,
    this.endedAt,
    this.challengeStartedAt,
    this.challengeEndsAt,
  });

  final String id;
  final String roomId;
  final MultiplayerGameState state;
  final int currentRoundOrder;
  final int currentChallengeOrder;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? challengeStartedAt;
  final DateTime? challengeEndsAt;

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      roomId: map['room_id'] as String? ?? '',
      state: MultiplayerGameState.fromValue(map['state'] as String? ?? 'waiting'),
      currentRoundOrder: map['current_round_order'] as int? ?? 1,
      currentChallengeOrder: map['current_challenge_order'] as int? ?? 1,
      startedAt: map['started_at'] == null ? null : DateTime.tryParse(map['started_at'] as String),
      endedAt: map['ended_at'] == null ? null : DateTime.tryParse(map['ended_at'] as String),
      challengeStartedAt: map['current_challenge_started_at'] == null ? null : DateTime.tryParse(map['current_challenge_started_at'] as String),
      challengeEndsAt: map['current_challenge_ends_at'] == null ? null : DateTime.tryParse(map['current_challenge_ends_at'] as String),
    );
  }
}

class GameChallenge {
  const GameChallenge({
    required this.id,
    required this.roundId,
    required this.challengeOrder,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.points,
    required this.options,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String roundId;
  final int challengeOrder;
  final ChallengeType type;
  final String prompt;
  final String correctAnswer;
  final int points;
  final List<String> options;
  final Map<String, dynamic> metadata;

  factory GameChallenge.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    return GameChallenge(
      id: map['id'] as String,
      roundId: map['round_id'] as String? ?? '',
      challengeOrder: map['challenge_order'] as int? ?? 1,
      type: ChallengeType.fromValue(map['type'] as String? ?? 'multiple_choice'),
      prompt: map['prompt'] as String? ?? '',
      correctAnswer: map['correct_answer'] as String? ?? '',
      points: map['points'] as int? ?? 0,
      options: rawOptions is List ? rawOptions.map((item) => item.toString()).toList() : const <String>[],
      metadata: map['metadata'] is Map ? Map<String, dynamic>.from(map['metadata'] as Map) : <String, dynamic>{},
    );
  }
}

class ScoreCalculator {
  ScoreCalculator._();

  static int pointsFor({required bool isCorrect, required int basePoints}) {
    return isCorrect ? basePoints : 0;
  }
}
