import 'package:flutter/material.dart';

import 'package:bible_memory_app_kids/ui/widgets/cloud_background.dart';

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold({super.key, this.appBar, required this.child, this.floatingActionButton});

  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: CloudBackground(
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
