import 'package:flutter/foundation.dart';

import '../models/game_config.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';
import '../services/supabase_client_provider.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({ProgressService? service}) : _service = service ?? ProgressService();

  final ProgressService _service;
  UserProgress _progress = UserProgress.empty();
  List<String> _favorites = [];

  UserProgress get progress => _progress;
  List<String> get favorites => _favorites;

  Future<void> load() async {
    final userId = await SupabaseClientProvider.ensureUser();
    if (userId == null) return;
    _progress = await _service.loadProgress(userId);
    _favorites = await _service.fetchFavorites(userId);
    notifyListeners();
  }

  Future<void> recordResult({required bool correct, required GameConfig config, required int score}) async {
    final userId = await SupabaseClientProvider.ensureUser();
    if (userId == null) return;

    _progress = UserProgress(
      totalVersesCompleted: _progress.totalVersesCompleted + (correct ? (config.toVerse - config.fromVerse + 1) : 0),
      totalGamesPlayed: _progress.totalGamesPlayed + 1,
      totalScore: _progress.totalScore + score,
      currentLevel: (_progress.totalScore + score) ~/ 50 + 1,
      lastGameConfig: config,
    );

    await _service.upsertProgress(userId, _progress);
    notifyListeners();
  }

  Future<void> toggleFavorite(String verseRef) async {
    final userId = await SupabaseClientProvider.ensureUser();
    if (userId == null) return;
    final isFavorite = _favorites.contains(verseRef);
    await _service.toggleFavorite(userId, verseRef, isFavorite);
    if (isFavorite) {
      _favorites.remove(verseRef);
    } else {
      _favorites.add(verseRef);
    }
    notifyListeners();
  }
}
