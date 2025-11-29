import 'game_config.dart';

class UserProgress {
  UserProgress({
    required this.totalVersesCompleted,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.currentLevel,
    this.lastGameConfig,
  });

  final int totalVersesCompleted;
  final int totalGamesPlayed;
  final int totalScore;
  final int currentLevel;
  final GameConfig? lastGameConfig;

  factory UserProgress.empty() => UserProgress(
        totalVersesCompleted: 0,
        totalGamesPlayed: 0,
        totalScore: 0,
        currentLevel: 1,
        lastGameConfig: null,
      );
}
