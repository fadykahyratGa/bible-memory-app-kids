import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../screens/badges_screen.dart';
import '../screens/range_selection_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/cloud_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_panel.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('احفظ كلمة الله', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BadgesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: CloudBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أهلاً بك في رحلة حفظ الكتاب المقدس للأطفال!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text('اختر مقطعك المفضل وابدأ لعبة "أكمل" لمراجعة الآيات.',
                    style: TextStyle(color: Colors.black54, height: 1.4)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.star_rounded, 'المستوى ${progress.currentLevel}'),
                    _buildInfoChip(
                        Icons.bookmark_added_rounded, 'آيات محفوظة ${progress.totalVersesCompleted}'),
                    _buildInfoChip(Icons.local_fire_department, 'مجموع النقاط ${progress.totalScore}'),
                  ],
                ),
                if (progress.lastGameConfig != null) ...[
                  const SizedBox(height: 16),
                  RoundedPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: AppColors.accentOrange, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('متابعة آخر جلسة',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                '${progress.lastGameConfig!.bookName} ${progress.lastGameConfig!.chapter}:${progress.lastGameConfig!.fromVerse}-${progress.lastGameConfig!.toVerse}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RangeSelectionScreen(preselected: progress.lastGameConfig),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                        )
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('ابدأ الآن',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'اختيار آيات جديدة',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RangeSelectionScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HomeActionTile(
                        title: 'بطاقات الإنجاز',
                        subtitle: 'اكتشف الأوسمة التي حصلت عليها',
                        color: AppColors.accentTeal,
                        icon: Icons.military_tech_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BadgesScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HomeActionTile(
                        title: 'الإعدادات',
                        subtitle: 'الصوت والصعوبة الافتراضية',
                        color: AppColors.accentOrange,
                        icon: Icons.settings_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.panelBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile(
      {required this.title, required this.subtitle, required this.color, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RoundedPanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
