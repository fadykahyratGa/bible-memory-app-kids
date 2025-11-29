import 'package:flutter/foundation.dart';

import '../models/game_config.dart';
import '../services/settings_service.dart';
import '../services/supabase_client_provider.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SettingsService? service}) : _service = service ?? SettingsService();

  final SettingsService _service;
  Difficulty _difficulty = Difficulty.easy;
  bool _soundEnabled = true;

  Difficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;

  Future<void> load() async {
    final userId = await SupabaseClientProvider.ensureUser();
    if (userId == null) return;
    _difficulty = await _service.loadDifficulty(userId);
    _soundEnabled = await _service.loadSoundEnabled(userId);
    notifyListeners();
  }

  Future<void> save(Difficulty difficulty, bool soundEnabled) async {
    final userId = await SupabaseClientProvider.ensureUser();
    if (userId == null) return;
    _difficulty = difficulty;
    _soundEnabled = soundEnabled;
    await _service.saveSettings(userId, difficulty, soundEnabled);
    notifyListeners();
  }
}
