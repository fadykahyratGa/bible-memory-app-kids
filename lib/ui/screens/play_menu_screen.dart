import 'package:flutter/material.dart';

import '../../models/game_config.dart';
import '../../theme/app_colors.dart';
import '../widgets/cloud_background.dart';
import '../widgets/rounded_panel.dart';
import 'range_selection_screen.dart';

class PlayMenuScreen extends StatelessWidget {
  const PlayMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play Memory Game')),
      body: CloudBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'اختر مستوى اللعب',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('تحدي الذاكرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          Icon(Icons.extension_rounded, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DifficultyCard(
                              label: 'سهل',
                              color: AppColors.accentOrange,
                              icon: Icons.sentiment_satisfied_alt_rounded,
                              onTap: () => _openRangeSelection(context, Difficulty.easy),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DifficultyCard(
                              label: 'متوسط',
                              color: AppColors.accentYellow,
                              icon: Icons.emoji_emotions_rounded,
                              onTap: () => _openRangeSelection(context, Difficulty.medium),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DifficultyCard(
                              label: 'صعب',
                              color: AppColors.primary,
                              icon: Icons.local_fire_department_rounded,
                              onTap: () => _openRangeSelection(context, Difficulty.hard),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RoundedPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                    ),
                    title: const Text('قائمة الآيات', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('اختر مقطعًا جديدًا للحفظ'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _openRangeSelection(context, Difficulty.easy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openRangeSelection(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RangeSelectionScreen(difficulty: difficulty)),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.label, required this.color, required this.icon, required this.onTap});

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
