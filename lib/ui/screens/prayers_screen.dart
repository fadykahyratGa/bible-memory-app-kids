import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../widgets/cloud_background.dart';
import '../widgets/rounded_panel.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleRequests = [
      'أشكر الله على محبته اليوم.',
      'صل من أجل أصدقائي في المدرسة.',
      'أعطني شجاعة لحفظ كلمة الله.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('صلواتي')),
      body: CloudBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('ضع طلبات صلاتك وتذكرها كل يوم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                );
              }
              final request = sampleRequests[index - 1];
              return RoundedPanel(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPink.withOpacity(0.15),
                        border: Border.all(color: AppColors.accentPink),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.accentPink),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(request, style: const TextStyle(fontSize: 16, height: 1.4)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.accentTeal),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: sampleRequests.length + 1,
          ),
        ),
      ),
    );
  }
}
