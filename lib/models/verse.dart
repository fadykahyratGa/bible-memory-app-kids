class Verse {
  const Verse({
    required this.ref,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.textAr,
  });

  final String ref;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String textAr;
}
