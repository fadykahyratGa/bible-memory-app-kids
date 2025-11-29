import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/arabic_bible_api_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/cloud_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_panel.dart';
import 'game_screen.dart';

class RangeSelectionScreen extends StatefulWidget {
  const RangeSelectionScreen({super.key, this.preselected, this.difficulty});

  final GameConfig? preselected;
  final Difficulty? difficulty;

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
  late Difficulty _selectedDifficulty;
  bool _loading = true;
  bool _chaptersLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty =
        widget.preselected?.difficulty ?? widget.difficulty ?? context.read<SettingsProvider>().difficulty;
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
      _chaptersInfo = chapters.isNotEmpty
          ? chapters
          : {
              for (final book in _books)
                book['id'] as int: book['chapters'] as int,
            };
      if (widget.preselected != null) {
        _selectedBookId = widget.preselected!.book;
        _selectedBookName = widget.preselected!.bookName;
        _chapter = widget.preselected!.chapter;
        _fromVerse = widget.preselected!.fromVerse;
        _toVerse = widget.preselected!.toVerse;
        _selectedDifficulty = widget.preselected!.difficulty;
      } else if (_books.isNotEmpty) {
        _selectedBookId = _books.first['id'] as int;
        _selectedBookName = _books.first['name'] as String;
      }
      _loading = false;
    });

    if (_selectedBookId != null && !_chaptersInfo.containsKey(_selectedBookId)) {
      await _ensureChapterInfo(_selectedBookId!);
    }
  }

  Future<void> _ensureChapterInfo(int bookId) async {
    if (_chaptersInfo.containsKey(bookId)) return;
    setState(() => _chaptersLoading = true);
    final count = await _apiService.fetchBookChapterCount(bookId);
    if (!mounted) return;
    setState(() {
      if (count != null) {
        _chaptersInfo[bookId] = count;
        _chapter = _chapter.clamp(1, count);
      }
      _chaptersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selectedBookChapters = _chaptersInfo[_selectedBookId ?? 0] ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار الآية')), 
      body: CloudBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 42),
                      SizedBox(height: 4),
                      Text('اختيار الآية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                RoundedPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedBookId,
                        borderRadius: BorderRadius.circular(16),
                        decoration: const InputDecoration(labelText: 'سفر:'),
                        items: _books
                            .map((b) => DropdownMenuItem<int>(
                                  value: b['id'] as int,
                                  child: Text(b['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() {
                          _selectedBookId = val;
                          _selectedBookName = _books.firstWhere((b) => b['id'] == val)['name'] as String;
                        }),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedBookChapters == 0
                            ? null
                            : _chapter.clamp(1, selectedBookChapters == 0 ? 1 : selectedBookChapters),
                        borderRadius: BorderRadius.circular(16),
                        decoration: const InputDecoration(labelText: 'إصحاح:'),
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.panelBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.accentOrange),
                            const SizedBox(width: 8),
                            const Text('الصعوبة:'),
                            const Spacer(),
                            DropdownButton<Difficulty>(
                              underline: const SizedBox.shrink(),
                              value: _selectedDifficulty,
                              items: Difficulty.values
                                  .map(
                                    (d) => DropdownMenuItem(value: d, child: Text(_difficultyLabel(d))),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedDifficulty = value);
                              },
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'انتقال',
                        onPressed: _selectedBookId == null
                            ? null
                            : () async {
                                final verses =
                                    await _apiService.fetchChapterVerses(bookId: _selectedBookId!, chapter: _chapter);
                                final maxVerse = verses.length;
                                final from = _fromVerse.clamp(1, maxVerse);
                                final to = _toVerse.clamp(from, maxVerse);
                                final config = GameConfig(
                                  book: _selectedBookId!,
                                  bookName: _selectedBookName,
                                  chapter: _chapter,
                                  fromVerse: from,
                                  toVerse: to,
                                  difficulty: _selectedDifficulty,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'سهل';
      case Difficulty.medium:
        return 'متوسط';
      case Difficulty.hard:
        return 'صعب';
    }
  }
}
