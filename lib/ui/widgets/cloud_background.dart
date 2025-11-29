import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CloudBackground extends StatelessWidget {
  const CloudBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyLight, AppColors.skyMedium, Colors.white],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: _CircleCloud(color: Colors.white.withOpacity(0.45), size: 140),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: _CircleCloud(color: Colors.white.withOpacity(0.35), size: 180),
          ),
          Positioned(
            bottom: -60,
            left: -20,
            child: _CircleCloud(color: AppColors.skyDeep.withOpacity(0.25), size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class _CircleCloud extends StatelessWidget {
  const _CircleCloud({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
}
