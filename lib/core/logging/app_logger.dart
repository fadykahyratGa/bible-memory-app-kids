import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String event, [Map<String, Object?> details = const {}]) {
    _log('info', event, details);
  }

  static void warning(String event, [Map<String, Object?> details = const {}]) {
    _log('warning', event, details);
  }

  static void error(String event, Object error, [Map<String, Object?> details = const {}]) {
    _log('error', event, <String, Object?>{
      ...details,
      'error': error.toString(),
    });
  }

  static void _log(String level, String event, Map<String, Object?> details) {
    final sanitized = <String, Object?>{};
    for (final entry in details.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('token') || key.contains('key') || key.contains('authorization')) {
        continue;
      }
      sanitized[entry.key] = entry.value;
    }

    debugPrint(
      jsonEncode(<String, Object?>{
        'level': level,
        'event': event,
        if (sanitized.isNotEmpty) 'details': sanitized,
      }),
    );
  }
}
