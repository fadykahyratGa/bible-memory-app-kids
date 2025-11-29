import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../widgets/cloud_background.dart';
import '../widgets/icon_badge.dart';
import '../widgets/rounded_panel.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _Badge(icon: Icons.menu_book_rounded, label: 'قارئ أمين', color: AppColors.primary),
      _Badge(icon: Icons.front_hand_rounded, label: 'الصديق الوفي', color: AppColors.accentOrange),
      _Badge(icon: Icons.eco_rounded, label: 'راعٍ صغير', color: AppColors.accentTeal),
      _Badge(icon: Icons.favorite_rounded, label: 'قلب محب', color: Colors.redAccent),
      _Badge(icon: Icons.home_rounded, label: 'بيت مبارك', color: Colors.orangeAccent),
      _Badge(icon: Icons.star_rounded, label: 'نجم الحفظ', color: AppColors.accentYellow),
      _Badge(icon: Icons.church_rounded, label: 'خادم الكنيسة', color: AppColors.primary),
      _Badge(icon: Icons.emoji_events_rounded, label: 'بطل الذاكرة', color: AppColors.accentPink),
      _Badge(icon: Icons.light_mode_rounded, label: 'نور مشع', color: Colors.amber),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('بطاقات الإنجاز')),
      body: CloudBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RoundedPanel(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Column(
                    children: const [
                      Text('Bible Memory Badges', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text('اجمع الأوسمة أثناء تقدمك في الحفظ',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return IconBadge(icon: badge.icon, label: badge.label, color: badge.color);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge {
  _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;
}
