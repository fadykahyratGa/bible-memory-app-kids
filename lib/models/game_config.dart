enum Difficulty { easy, medium, hard }

class GameConfig {
  const GameConfig({
    required this.book,
    required this.bookName,
    required this.chapter,
    required this.fromVerse,
    required this.toVerse,
    required this.difficulty,
  });

  final int book;
  final String bookName;
  final int chapter;
  final int fromVerse;
  final int toVerse;
  final Difficulty difficulty;

  Map<String, dynamic> toJson() => {
        'book': book,
        'bookName': bookName,
        'chapter': chapter,
        'fromVerse': fromVerse,
        'toVerse': toVerse,
        'difficulty': difficulty.name,
      };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      book: json['book'] as int,
      bookName: json['bookName'] as String,
      chapter: json['chapter'] as int,
      fromVerse: json['fromVerse'] as int,
      toVerse: json['toVerse'] as int,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
    );
  }
}
