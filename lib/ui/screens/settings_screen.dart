import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/settings_provider.dart';
import '../widgets/primary_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Difficulty? _difficulty;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SettingsProvider>();
      provider.load().then((_) {
        setState(() {
          _difficulty = provider.difficulty;
          _soundEnabled = provider.soundEnabled;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Difficulty>(
              value: _difficulty ?? provider.difficulty,
              decoration: const InputDecoration(labelText: 'درجة الصعوبة الافتراضية'),
              items: Difficulty.values
                  .map((d) => DropdownMenuItem(value: d, child: Text(_difficultyLabel(d))))
                  .toList(),
              onChanged: (val) => setState(() => _difficulty = val),
            ),
            SwitchListTile(
              title: const Text('تشغيل الصوت'),
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'حفظ',
              onPressed: () {
                provider.save(_difficulty ?? provider.difficulty, _soundEnabled);
                Navigator.pop(context);
              },
            ),
          ],
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
