import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.accentTeal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 78,
          width: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: resolvedColor.withOpacity(0.2),
            border: Border.all(color: resolvedColor, width: 3),
            boxShadow: [
              BoxShadow(color: resolvedColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(icon, size: 36, color: resolvedColor),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
