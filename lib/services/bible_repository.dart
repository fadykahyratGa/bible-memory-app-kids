import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import '../models/verse.dart';
import 'supabase_client_provider.dart';

/// BibleRepository provides access to Bible text stored in Supabase.
/// 
/// Example SQL schema for Supabase:
/// ```sql
/// -- Books table
/// create table if not exists books (
///   id serial primary key,
///   numeric_id int unique not null,
///   name_ar text not null,
///   chapters_count int not null,
///   created_at timestamptz default now()
/// );
/// 
/// -- Verses table
/// create table if not exists verses (
///   id serial primary key,
///   ref text unique not null,
///   book_id int references books(numeric_id) on delete cascade,
///   book_name text not null,
///   chapter int not null,
///   verse_number int not null,
///   text_ar text not null,
///   created_at timestamptz default now()
/// );
/// 
/// -- Index for faster queries
/// create index if not exists idx_verses_book_chapter 
///   on verses(book_id, chapter);
/// create index if not exists idx_verses_ref 
///   on verses(ref);
/// ```
class BibleRepository {
  BibleRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;

  /// Fetch all books from Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final books = await repository.fetchBooks();
  /// ```
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await _client
          .from('books')
          .select()
          .order('numeric_id');

      return (response as List<dynamic>)
          .map((json) => Book(
                id: json['numeric_id'].toString(),
                nameAr: json['name_ar'] as String,
                chaptersCount: json['chapters_count'] as int,
                numericId: json['numeric_id'] as int,
              ))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist or query fails
      return [];
    }
  }

  /// Fetch a specific book by ID from Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final book = await repository.fetchBook(50); // Matthew
  /// ```
  Future<Book?> fetchBook(int bookId) async {
    try {
      final response = await _client
          .from('books')
          .select()
          .eq('numeric_id', bookId)
          .maybeSingle();

      if (response == null) return null;

      return Book(
        id: response['numeric_id'].toString(),
        nameAr: response['name_ar'] as String,
        chaptersCount: response['chapters_count'] as int,
        numericId: response['numeric_id'] as int,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch verses for a specific chapter from Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final verses = await repository.fetchChapterVerses(
  ///   bookId: 50,
  ///   chapter: 5,
  /// );
  /// ```
  Future<List<Verse>> fetchChapterVerses({
    required int bookId,
    required int chapter,
  }) async {
    try {
      final response = await _client
          .from('verses')
          .select()
          .eq('book_id', bookId)
          .eq('chapter', chapter)
          .order('verse_number');

      return (response as List<dynamic>)
          .map((json) => Verse(
                ref: json['ref'] as String,
                bookId: json['book_id'].toString(),
                bookName: json['book_name'] as String,
                chapter: json['chapter'] as int,
                verseNumber: json['verse_number'] as int,
                textAr: json['text_ar'] as String,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a range of verses from Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final verses = await repository.fetchVerseRange(
  ///   bookId: 50,
  ///   chapter: 5,
  ///   fromVerse: 3,
  ///   toVerse: 12,
  /// );
  /// ```
  Future<List<Verse>> fetchVerseRange({
    required int bookId,
    required int chapter,
    required int fromVerse,
    required int toVerse,
  }) async {
    try {
      final response = await _client
          .from('verses')
          .select()
          .eq('book_id', bookId)
          .eq('chapter', chapter)
          .gte('verse_number', fromVerse)
          .lte('verse_number', toVerse)
          .order('verse_number');

      return (response as List<dynamic>)
          .map((json) => Verse(
                ref: json['ref'] as String,
                bookId: json['book_id'].toString(),
                bookName: json['book_name'] as String,
                chapter: json['chapter'] as int,
                verseNumber: json['verse_number'] as int,
                textAr: json['text_ar'] as String,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single verse by reference from Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final verse = await repository.fetchVerseByRef('50-5-3');
  /// ```
  Future<Verse?> fetchVerseByRef(String ref) async {
    try {
      final response = await _client
          .from('verses')
          .select()
          .eq('ref', ref)
          .maybeSingle();

      if (response == null) return null;

      return Verse(
        ref: response['ref'] as String,
        bookId: response['book_id'].toString(),
        bookName: response['book_name'] as String,
        chapter: response['chapter'] as int,
        verseNumber: response['verse_number'] as int,
        textAr: response['text_ar'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  /// Search verses by text in Supabase
  /// 
  /// Example query:
  /// ```dart
  /// final verses = await repository.searchVerses('محبة');
  /// ```
  Future<List<Verse>> searchVerses(String query) async {
    try {
      final response = await _client
          .from('verses')
          .select()
          .ilike('text_ar', '%$query%')
          .limit(50);

      return (response as List<dynamic>)
          .map((json) => Verse(
                ref: json['ref'] as String,
                bookId: json['book_id'].toString(),
                bookName: json['book_name'] as String,
                chapter: json['chapter'] as int,
                verseNumber: json['verse_number'] as int,
                textAr: json['text_ar'] as String,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
