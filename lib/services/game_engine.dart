import 'dart:math';

import '../models/game_config.dart';
import '../models/question.dart';
import '../models/verse.dart';

class GameEngine {
  List<Question> buildQuestions(List<Verse> verses, Difficulty difficulty) {
    return verses.map((verse) => _buildQuestion(verse, difficulty)).toList();
  }

  Question _buildQuestion(Verse verse, Difficulty difficulty) {
    final words = verse.textAr.split(' ');
    final random = Random(verse.textAr.length);
    final hiddenCount = _hiddenWordsCount(words.length, difficulty);
    final hiddenIndexes = <int>{};

    while (hiddenIndexes.length < hiddenCount) {
      hiddenIndexes.add(random.nextInt(words.length));
    }

    final hiddenWords = hiddenIndexes.map((i) => words[i]).toList();
    final maskedWords = words
        .asMap()
        .entries
        .map((entry) => hiddenIndexes.contains(entry.key) ? '____' : entry.value)
        .toList();

    final options = [...hiddenWords];
    while (options.length < hiddenWords.length + 3) {
      options.add(_randomNoiseWord(random));
    }
    options.shuffle(random);

    return Question(
      verse: verse,
      hiddenWords: hiddenWords,
      options: options,
      maskedText: maskedWords.join(' '),
    );
  }

  bool isAnswerCorrect(Question question, List<String> userAnswer) {
    if (userAnswer.length != question.hiddenWords.length) return false;
    final sortedUser = [...userAnswer]..sort();
    final sortedCorrect = [...question.hiddenWords]..sort();
    for (var i = 0; i < sortedCorrect.length; i++) {
      if (sortedCorrect[i] != sortedUser[i]) return false;
    }
    return true;
  }

  int calculateScore({
    required Difficulty difficulty,
    required bool correct,
  }) {
    final base = switch (difficulty) {
      Difficulty.easy => 5,
      Difficulty.medium => 10,
      Difficulty.hard => 15,
    };
    return correct ? base : 0;
  }

  int _hiddenWordsCount(int wordCount, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return max(1, wordCount ~/ 6);
      case Difficulty.medium:
        return max(2, wordCount ~/ 5);
      case Difficulty.hard:
        return max(3, wordCount ~/ 4);
    }
  }

  String _randomNoiseWord(Random random) {
    const noise = ['سلام', 'محبة', 'رجاء', 'إيمان', 'نور', 'حياة', 'نعمة'];
    return noise[random.nextInt(noise.length)];
  }
}
