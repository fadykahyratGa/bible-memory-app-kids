import 'game_config.dart';
import 'question.dart';

enum GameStatus { inProgress, completed }

class GameState {
  GameState({
    required this.config,
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.status = GameStatus.inProgress,
  });

  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int correctCount;
  final int wrongCount;
  final GameStatus status;

  Question get currentQuestion => questions[currentIndex];

  GameState copyWith({
    int? currentIndex,
    int? score,
    int? correctCount,
    int? wrongCount,
    GameStatus? status,
  }) {
    return GameState(
      config: config,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      status: status ?? this.status,
    );
  }
}
