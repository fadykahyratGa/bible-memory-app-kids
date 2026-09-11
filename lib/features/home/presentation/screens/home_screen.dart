import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../ui/widgets/cloud_background.dart';
import '../../../../ui/widgets/rounded_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
          ),
        ],
      ),
      body: CloudBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحبًا ${authState.profile?.displayName ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(authState.isGuest ? 'أنت تلعب الآن كضيف' : 'تم تسجيل الدخول بنجاح'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _HomeActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'إنشاء غرفة',
                  onTap: () => context.go('/create-room'),
                ),
                const SizedBox(height: 12),
                _HomeActionButton(
                  icon: Icons.login_rounded,
                  label: 'انضمام لغرفة',
                  onTap: () => context.go('/join-room'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ستتم إضافة وضع اللعب الفعلي في الدفعة التالية بعد اكتمال الردهات والتهيئة الزمنية.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
