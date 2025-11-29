import 'verse.dart';

class Question {
  Question({
    required this.verse,
    required this.hiddenWords,
    required this.options,
    required this.maskedText,
  });

  final Verse verse;
  final List<String> hiddenWords;
  final List<String> options;
  final String maskedText;
}
