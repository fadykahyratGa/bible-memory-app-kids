import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/game_provider.dart';
import '../../services/arabic_bible_api_service.dart';
import '../widgets/primary_button.dart';
import 'game_screen.dart';

class RangeSelectionScreen extends StatefulWidget {
  const RangeSelectionScreen({super.key, this.preselected});

  final GameConfig? preselected;

  @override
  State<RangeSelectionScreen> createState() => _RangeSelectionScreenState();
}

class _RangeSelectionScreenState extends State<RangeSelectionScreen> {
  final ArabicBibleApiService _apiService = ArabicBibleApiService();
  List<Map<String, dynamic>> _books = [];
  Map<int, int> _chaptersInfo = {};
  int? _selectedBookId;
  String _selectedBookName = '';
  int _chapter = 1;
  int _fromVerse = 1;
  int _toVerse = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final books = await _apiService.fetchBooks();
    final chapters = await _apiService.fetchChaptersInfo();
    setState(() {
      _books = books
          .map((b) => {
                'id': b.numericId,
                'name': b.nameAr,
                'chapters': b.chaptersCount,
              })
          .toList();
      _chaptersInfo = chapters;
      if (widget.preselected != null) {
        _selectedBookId = widget.preselected!.book;
        _selectedBookName = widget.preselected!.bookName;
        _chapter = widget.preselected!.chapter;
        _fromVerse = widget.preselected!.fromVerse;
        _toVerse = widget.preselected!.toVerse;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selectedBookChapters = _chaptersInfo[_selectedBookId ?? 0] ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار مقطع')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedBookId,
              decoration: const InputDecoration(labelText: 'السفر'),
              items: _books
                  .map((b) => DropdownMenuItem<int>(
                        value: b['id'] as int,
                        child: Text(b['name'] as String),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedBookId = val;
                _selectedBookName = _books.firstWhere((b) => b['id'] == val)['name'] as String;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _chapter,
              decoration: const InputDecoration(labelText: 'الإصحاح'),
              items: List.generate(selectedBookChapters, (index) => index + 1)
                  .map((c) => DropdownMenuItem<int>(value: c, child: Text('$c')))
                  .toList(),
              onChanged: (val) => setState(() => _chapter = val ?? 1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '$_fromVerse',
                    decoration: const InputDecoration(labelText: 'من عدد'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _fromVerse = int.tryParse(val) ?? 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '$_toVerse',
                    decoration: const InputDecoration(labelText: 'إلى عدد'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _toVerse = int.tryParse(val) ?? _fromVerse,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'انتقال',
              onPressed: _selectedBookId == null
                  ? null
                  : () async {
                      final verses = await _apiService.fetchChapterVerses(bookId: _selectedBookId!, chapter: _chapter);
                      final maxVerse = verses.length;
                      final from = _fromVerse.clamp(1, maxVerse);
                      final to = _toVerse.clamp(from, maxVerse);
                      final config = GameConfig(
                        book: _selectedBookId!,
                        bookName: _selectedBookName,
                        chapter: _chapter,
                        fromVerse: from,
                        toVerse: to,
                        difficulty: context.read<GameProvider>().state?.config.difficulty ?? Difficulty.easy,
                      );
                      await context.read<GameProvider>().startGame(config);
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
