import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../ui/widgets/cloud_background.dart';
import '../../../../ui/widgets/primary_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CloudBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(Icons.groups_rounded, size: 88, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'لعبة تحدي الصور المسيحية',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ادخل كضيف أو أنشئ حسابًا وابدأ اللعب مع أصدقائك.',
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                PrimaryButton(label: 'المتابعة كضيف', onPressed: () => context.go('/guest-name')),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/sign-in'),
                  child: const Text('تسجيل الدخول'),
                ),
                TextButton(
                  onPressed: () => context.go('/sign-up'),
                  child: const Text('إنشاء حساب جديد'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
