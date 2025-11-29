import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/verse.dart';

class ArabicBibleApiService {
  ArabicBibleApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://arabic-bible.onrender.com';
  final http.Client _client;

  final Set<String> _excludedBooks = const {
    'طوبيا',
    'يهوديت',
    'تتمة سفر أستير',
    'المزمور المائة والحادي والحمسون',
    'سفر الحكمة',
    'سفر يشوع بن سيراخ',
    'سفر باروخ',
    'تتمة سفر دانيال',
    'سفر المكابيين الأول',
    'سفر المكابيين الثاني',
  };

  Future<List<Book>> fetchBooks() async {
    final uri = Uri.parse('$_baseUrl/api/json/books');
    final response = await _safeGet(uri);
    if (response == null) return [];

    final data = jsonDecode(response) as List<dynamic>;
    final filtered = data.where((book) => !_excludedBooks.contains(book['name'])).toList();

    return filtered
        .map(
          (book) => Book(
            id: book['id'].toString(),
            nameAr: book['name'] as String,
            chaptersCount: int.tryParse(book['chapters'].toString()) ?? 0,
            numericId: int.tryParse(book['id'].toString()) ?? 0,
          ),
        )
        .toList();
  }

  Future<Map<int, int>> fetchChaptersInfo() async {
    final uri = Uri.parse('$_baseUrl/api/json/chapters');
    final response = await _safeGet(uri);
    if (response == null) return {};

    final data = jsonDecode(response) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(int.parse(key), value as int));
  }

  Future<List<String>> fetchChapterVerses({required int bookId, required int chapter}) async {
    final uri = Uri.parse('$_baseUrl/api?book=$bookId&ch=$chapter');
    final response = await _safeGet(uri);
    if (response == null) return [];
    final data = jsonDecode(response) as Map<String, dynamic>;
    final arr = (data['arr'] as List<dynamic>? ?? []).cast<String>();
    return arr;
  }

  Future<List<Verse>> fetchVerseRange({
    required int bookId,
    required String bookName,
    required int chapter,
    required int from,
    required int to,
  }) async {
    final uri = Uri.parse('$_baseUrl/api?book=$bookId&ch=$chapter&ver=$from:$to');
    final response = await _safeGet(uri);
    if (response == null) return [];
    final data = jsonDecode(response) as Map<String, dynamic>;
    final arr = (data['arr'] as List<dynamic>? ?? []).cast<String>();

    final verses = <Verse>[];
    for (var i = 0; i < arr.length; i++) {
      final verseNumber = from + i;
      verses.add(
        Verse(
          ref: '$bookId-$chapter-$verseNumber',
          bookId: bookId.toString(),
          bookName: bookName,
          chapter: chapter,
          verseNumber: verseNumber,
          textAr: arr[i],
        ),
      );
    }
    return verses;
  }

  Future<String?> _safeGet(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.body;
      }
    } on SocketException {
      return null;
    } on http.ClientException {
      return null;
    }
    return null;
  }
}
