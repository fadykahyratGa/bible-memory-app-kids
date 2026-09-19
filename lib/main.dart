import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/app.dart';
import 'package:bible_memory_app_kids/core/config/app_config.dart';
import 'package:bible_memory_app_kids/core/logging/app_logger.dart';
import 'package:bible_memory_app_kids/services/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await SupabaseClientProvider.initialize(config);
  AppLogger.info('app.main.ready', <String, Object?>{'configured': config.isConfigured});
  runApp(const ProviderScope(child: BibleMemoryApp()));
}
