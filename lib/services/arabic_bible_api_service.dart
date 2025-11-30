import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/verse.dart';

class ArabicBibleApiService {
  ArabicBibleApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://arabic-bible.onrender.com';
  final http.Client _client;

  static const Set<String> _excludedBooks = {
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

  static const Map<int, String> _canonicalBooks = {
    1: 'سفر التكوين',
    2: 'سفر الخروج',
    3: 'سفر اللاويين',
    4: 'سفر العدد',
    5: 'سفر التثنية',
    6: 'سفر يشوع',
    7: 'سفر القضاة',
    8: 'سفر راعوث',
    9: 'سفر صموئيل الأول',
    10: 'سفر صموئيل الثاني',
    11: 'سفر الملوك الأول',
    12: 'سفر الملوك الثاني',
    13: 'سفر أخبار الأيام الأول',
    14: 'سفر أخبار الأيام الثاني',
    15: 'سفر عزرا',
    16: 'سفر نحميا',
    17: 'سفر أستير',
    18: 'سفر أيوب',
    19: 'سفر المزامير',
    20: 'سفر الأمثال',
    21: 'سفر الجامعة',
    22: 'سفر نشيد الأنشاد',
    23: 'سفر إشعياء',
    24: 'سفر إرميا',
    25: 'سفر مراثي إرميا',
    26: 'سفر حزقيال',
    27: 'سفر دانيال',
    28: 'سفر هوشع',
    29: 'سفر يوئيل',
    30: 'سفر عاموس',
    31: 'سفر عوبديا',
    32: 'سفر يونان',
    33: 'سفر ميخا',
    34: 'سفر ناحوم',
    35: 'سفر حبقوق',
    36: 'سفر صفنيا',
    37: 'سفر حجي',
    38: 'سفر زكريا',
    39: 'سفر ملاخي',
    40: 'إنجيل متى',
    41: 'إنجيل مرقس',
    42: 'إنجيل لوقا',
    43: 'إنجيل يوحنا',
    44: 'سفر أعمال الرسل',
    45: 'رسالة بولس الرسول إلى أهل رومية',
    46: 'رسالة بولس الرسول الأولى إلى أهل كورنثوس',
    47: 'رسالة بولس الرسول الثانية إلى أهل كورنثوس',
    48: 'رسالة بولس الرسول إلى أهل غلاطية',
    49: 'رسالة بولس الرسول إلى أهل أفسس',
    50: 'رسالة بولس الرسول إلى أهل فيلبي',
    51: 'رسالة بولس الرسول إلى أهل كولوسي',
    52: 'رسالة بولس الرسول الأولى إلى أهل تسالونيكي',
    53: 'رسالة بولس الرسول الثانية إلى أهل تسالونيكي',
    54: 'رسالة بولس الرسول الأولى إلى تيموثاوس',
    55: 'رسالة بولس الرسول الثانية إلى تيموثاوس',
    56: 'رسالة بولس الرسول إلى تيطس',
    57: 'رسالة بولس الرسول إلى فليمون',
    58: 'رسالة بولس الرسول إلى العبرانيين',
    59: 'رسالة يعقوب',
    60: 'رسالة بطرس الرسول الأولى',
    61: 'رسالة بطرس الرسول الثانية',
    62: 'رسالة يوحنا الرسول الأولى',
    63: 'رسالة يوحنا الرسول الثانية',
    64: 'رسالة يوحنا الرسول الثالثة',
    65: 'رسالة يهوذا',
    66: 'سفر رؤيا يوحنا اللاهوتي',
  };

  Future<List<Book>> fetchBooks() async {
    final uri = Uri.parse('$_baseUrl/api/json/books');
    final response = await _safeGet(uri);
    if (response == null || response.isEmpty) {
      return _canonicalBooks.entries
          .map(
            (entry) => Book(
              id: entry.key.toString(),
              nameAr: entry.value,
              chaptersCount: 0,
              numericId: entry.key,
            ),
          )
          .toList();
    }

    final decoded = jsonDecode(response);
    final data = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
            ? decoded['arr'] as List<dynamic>? ??
                decoded['books'] as List<dynamic>? ??
                decoded.values.firstWhere((v) => v is List<dynamic>, orElse: () => []) as List<dynamic>
            : [];

    final filtered = data
        .whereType<Map<String, dynamic>>()
        .where(
          (book) => !_excludedBooks.contains(book['name']) &&
              _canonicalBooks.containsValue(book['name']),
        )
        .toList();

    final parsed = filtered.map(
      (book) => Book(
        id: book['id'].toString(),
        nameAr: book['name'] as String,
        chaptersCount: int.tryParse(book['chapters'].toString()) ?? 0,
        numericId: int.tryParse(book['id'].toString()) ?? 0,
      ),
    );

    final books = parsed.toList();
    if (books.isNotEmpty) return books;

    // Fallback to the known list of books if the API shape changes again.
    return _canonicalBooks.entries
        .map(
          (entry) => Book(
            id: entry.key.toString(),
            nameAr: entry.value,
            chaptersCount: 0,
            numericId: entry.key,
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

  Future<int?> fetchBookChapterCount(int bookId) async {
    final uri = Uri.parse('$_baseUrl/api?book=$bookId');
    final response = await _safeGet(uri);
    if (response == null) return null;

    try {
      final data = jsonDecode(response) as Map<String, dynamic>;
      return int.tryParse(data['chapters'].toString());
    } catch (_) {
      return null;
    }
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
      debugPrint('ArabicBibleApiService request failed: ${response.statusCode} for $uri');
    } on SocketException {
      debugPrint('ArabicBibleApiService network error for $uri');
      return null;
    } on http.ClientException {
      debugPrint('ArabicBibleApiService client error for $uri');
      return null;
    }
    return null;
  }
}
