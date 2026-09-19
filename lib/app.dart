import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as legacy_provider;

import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/core/router/app_router.dart';
import 'package:bible_memory_app_kids/providers/game_provider.dart';
import 'package:bible_memory_app_kids/providers/progress_provider.dart';
import 'package:bible_memory_app_kids/providers/settings_provider.dart';
import 'package:bible_memory_app_kids/theme/app_theme.dart';

class BibleMemoryApp extends ConsumerWidget {
  const BibleMemoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return legacy_provider.MultiProvider(
      providers: [
        legacy_provider.ChangeNotifierProvider(create: (_) => SettingsProvider()),
        legacy_provider.ChangeNotifierProvider(create: (_) => ProgressProvider()),
        legacy_provider.ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.buildTheme(GoogleFonts.cairoTextTheme()),
        routerConfig: router,
      ),
    );
  }
}
