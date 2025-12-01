import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/verse.dart';

class ArabicBibleApiService {
  ArabicBibleApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://arabic-bible.onrender.com';
  final http.Client _client;

  // Books to exclude from the API response if needed
  static const Set<String> _excludedBooks = {};

  static const Map<int, String> _fallbackBooks = {
    1: "سفر التكوين",
    2: "سفر الخروج",
    3: "سفر اللاويين",
    4: "سفر العدد",
    5: "سفر التثنية",
    6: "سفر يشوع",
    7: "سفر القضاة",
    8: "سفر راعوث",
    9: "سفر صموئيل الأول",
    10: "سفر صموئيل الثاني",
    11: "سفر الملوك الأول",
    12: "سفر الملوك الثاني",
    13: "سفر أخبار الأيام الأول",
    14: "سفر أخبار الأيام الثاني",
    15: "سفر عزرا",
    16: "سفر نحميا",
    17: "سفر طوبيا",
    18: "سفر يهوديت",
    19: "سفر أستير",
    20: "تتمة سفر أستير",
    21: "سفر أيوب",
    22: "سفر المزامير",
    23: "المزمور المائة والحادي والحمسون",
    24: "سفر الأمثال",
    25: "سفر الجامعة",
    26: "سفر نشيد الأنشاد",
    27: "سفر الحكمة",
    28: "سفر يشوع بن سيراخ",
    29: "سفر إشعياء",
    30: "سفر إرميا",
    31: "سفر مراثي إرميا",
    32: "سفر باروخ",
    33: "سفر حزقيال",
    34: "سفر دانيال",
    35: "تتمة سفر دانيال",
    36: "سفر هوشع",
    37: "سفر يوئيل",
    38: "سفر عاموس",
    39: "سفر عوبديا",
    40: "سفر يونان",
    41: "سفر ميخا",
    42: "سفر ناحوم",
    43: "سفر حبقوق",
    44: "سفر صفنيا",
    45: "سفر حجي",
    46: "سفر زكريا",
    47: "سفر ملاخي",
    48: "سفر المكابيين الأول",
    49: "سفر المكابيين الثاني",
    50: "إنجيل متى",
    51: "إنجيل مرقس",
    52: "إنجيل لوقا",
    53: "إنجيل يوحنا",
    54: "سفر أعمال الرسل",
    55: "رسالة بولس الرسول إلى أهل رومية",
    56: "رسالة بولس الرسول الأولى إلى أهل كورنثوس",
    57: "رسالة بولس الرسول الثانية إلى أهل كورنثوس",
    58: "رسالة بولس الرسول إلى أهل غلاطية",
    59: "رسالة بولس الرسول إلى أهل أفسس",
    60: "رسالة بولس الرسول إلى أهل فيلبي",
    61: "رسالة بولس الرسول إلى أهل كولوسي",
    62: "رسالة بولس الرسول الأولى إلى أهل تسالونيكي",
    63: "رسالة بولس الرسول الثانية إلى أهل تسالونيكي",
    64: "رسالة بولس الرسول الأولى إلى تيموثاوس",
    65: "رسالة بولس الرسول الثانية إلى تيموثاوس",
    66: "رسالة بولس الرسول إلى تيطس",
    67: "رسالة بولس الرسول إلى فليمون",
    68: "رسالة بولس الرسول إلى العبرانيين",
    69: "رسالة يعقوب",
    70: "رسالة بطرس الرسول الأولى",
    71: "رسالة بطرس الرسول الثانية",
    72: "رسالة يوحنا الرسول الأولى",
    73: "رسالة يوحنا الرسول الثانية",
    74: "رسالة يوحنا الرسول الثالثة",
    75: "رسالة يهوذا",
    76: "سفر رؤيا يوحنا اللاهوتي",
  };

  Future<List<Book>> fetchBooks() async {
    final uri = Uri.parse('$_baseUrl/api/json/books');
    final response = await _safeGet(uri);
    if (response == null || response.isEmpty) {
      return _fallbackBooks.entries
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
        .where((book) => !_excludedBooks.contains(book['name']))
        .toList();

    final parsed = data.whereType<Map<String, dynamic>>().map(
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
    return _fallbackBooks.entries
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
    } on SocketException {
      return null;
    } on http.ClientException {
      return null;
    }
    return null;
  }
}
