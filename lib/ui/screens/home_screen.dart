import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/progress_provider.dart';
import '../../ui/screens/badges_screen.dart';
import '../../ui/screens/range_selection_screen.dart';
import '../../ui/screens/settings_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;
    return Scaffold(
      appBar: AppBar(
        title: const Text('احفظ كلمة الله'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BadgesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('المستوى الحالي: ${progress.currentLevel}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('آيات منجزة: ${progress.totalVersesCompleted}'),
                  Text('مجموع النقاط: ${progress.totalScore}'),
                ],
              ),
            ),
            if (progress.lastGameConfig != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('آخر جلسة', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${progress.lastGameConfig!.bookName} ${progress.lastGameConfig!.chapter}:${progress.lastGameConfig!.fromVerse}-${progress.lastGameConfig!.toVerse}'),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'متابعة',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RangeSelectionScreen(preselected: progress.lastGameConfig),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'اختيار آيات جديدة',
              icon: Icons.play_arrow,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RangeSelectionScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
