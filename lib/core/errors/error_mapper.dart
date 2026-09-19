import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';

class AppErrorMapper {
  AppErrorMapper._();

  static const roomNotFoundMessage = 'الغرفة غير موجودة
تأكد من كود الغرفة وحاول مرة أخرى.';
  static const roomStartedMessage = 'اللعبة بدأت بالفعل ولا يمكن الانضمام الآن.';
  static const connectionProblemMessage = 'حدثت مشكلة في الاتصال.
جاري إعادة المحاولة...';
  static const missingConfigMessage = 'إعدادات Supabase غير مكتملة.
أضف SUPABASE_URL وSUPABASE_ANON_KEY ثم أعد تشغيل التطبيق.';
  static const genericMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is PostgrestException) {
      final message = error.message.toUpperCase();
      if (message.contains('ROOM_NOT_FOUND')) {
        return AppException(code: 'room_not_found', userMessage: roomNotFoundMessage, debugMessage: error.message);
      }
      if (message.contains('ROOM_STARTED')) {
        return AppException(code: 'room_started', userMessage: roomStartedMessage, debugMessage: error.message);
      }
      if (message.contains('NOT_HOST')) {
        return AppException(code: 'not_host', userMessage: 'فقط صاحب الغرفة يمكنه تنفيذ هذا الإجراء.', debugMessage: error.message);
      }
      if (message.contains('PROFILE_REQUIRED')) {
        return AppException(code: 'profile_required', userMessage: 'من فضلك أكمل اسمك أولاً.', debugMessage: error.message);
      }
      return AppException(code: error.code ?? 'postgres_error', userMessage: genericMessage, debugMessage: error.message);
    }

    if (error is AuthException) {
      return AppException(code: 'auth_error', userMessage: connectionProblemMessage, debugMessage: error.message);
    }

    if (error is SocketException) {
      return const AppException(code: 'socket_error', userMessage: connectionProblemMessage);
    }

    return AppException(code: 'unknown', userMessage: genericMessage, debugMessage: error.toString());
  }
}
