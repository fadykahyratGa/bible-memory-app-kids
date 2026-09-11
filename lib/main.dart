import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.initialize();
  runApp(const ProviderScope(child: BibleMemoryApp()));
}
