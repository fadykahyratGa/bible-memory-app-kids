import 'package:flutter/foundation.dart';

import '../models/game_config.dart';
import '../models/game_state.dart';
import '../models/verse.dart';
import '../services/arabic_bible_api_service.dart';
import '../services/game_engine.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({ArabicBibleApiService? apiService, GameEngine? engine})
      : _apiService = apiService ?? ArabicBibleApiService(),
        _engine = engine ?? GameEngine();

  final ArabicBibleApiService _apiService;
  final GameEngine _engine;

  GameState? _state;
  List<String> _currentAnswer = [];

  GameState? get state => _state;
  List<String> get currentAnswer => _currentAnswer;

  Future<void> startGame(GameConfig config) async {
    final verses = await _apiService.fetchVerseRange(
      bookId: config.book,
      bookName: config.bookName,
      chapter: config.chapter,
      from: config.fromVerse,
      to: config.toVerse,
    );
    final questions = _engine.buildQuestions(verses, config.difficulty);
    _state = GameState(config: config, questions: questions);
    _currentAnswer = [];
    notifyListeners();
  }

  void addAnswer(String word) {
    _currentAnswer = [..._currentAnswer, word];
    notifyListeners();
  }

  void removeAnswer(String word) {
    _currentAnswer = List.of(_currentAnswer)..remove(word);
    notifyListeners();
  }

  bool checkAnswer() {
    if (_state == null) return false;
    final correct = _engine.isAnswerCorrect(_state!.currentQuestion, _currentAnswer);
    final scoreDelta = _engine.calculateScore(difficulty: _state!.config.difficulty, correct: correct);
    _state = _state!.copyWith(
      score: _state!.score + scoreDelta,
      correctCount: _state!.correctCount + (correct ? 1 : 0),
      wrongCount: _state!.wrongCount + (correct ? 0 : 1),
    );
    notifyListeners();
    return correct;
  }

  bool nextQuestion() {
    if (_state == null) return false;
    final nextIndex = _state!.currentIndex + 1;
    if (nextIndex >= _state!.questions.length) {
      _state = _state!.copyWith(status: GameStatus.completed);
      notifyListeners();
      return false;
    }
    _state = _state!.copyWith(currentIndex: nextIndex);
    _currentAnswer = [];
    notifyListeners();
    return true;
  }
}
