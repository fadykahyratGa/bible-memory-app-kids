import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class RoundedPanel extends StatelessWidget {
  const RoundedPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.panelBorder, width: 1.4),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 6), blurRadius: 18, color: Colors.black12),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
