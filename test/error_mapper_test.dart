import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';

void main() {
  test('maps room not found postgres errors to friendly Arabic text', () {
    final exception = PostgrestException(message: 'ROOM_NOT_FOUND', code: 'P0001', details: '');
    expect(AppErrorMapper.map(exception).userMessage, AppErrorMapper.roomNotFoundMessage);
  });

  test('maps room started postgres errors to friendly Arabic text', () {
    final exception = PostgrestException(message: 'ROOM_STARTED', code: 'P0001', details: '');
    expect(AppErrorMapper.map(exception).userMessage, AppErrorMapper.roomStartedMessage);
  });

  test('maps connection failures to retry message', () {
    expect(AppErrorMapper.map(const SocketException('offline')).userMessage, AppErrorMapper.connectionProblemMessage);
    expect(AppErrorMapper.map(AuthException('auth failed')).userMessage, AppErrorMapper.connectionProblemMessage);
  });
}
