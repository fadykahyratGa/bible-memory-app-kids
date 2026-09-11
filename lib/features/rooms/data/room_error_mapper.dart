class RoomException implements Exception {
  const RoomException(this.message);

  final String message;

  @override
  String toString() => message;
}

RoomException mapRoomError(Object error) {
  final raw = error.toString();

  if (raw.contains('INVALID_ROOM_CODE')) {
    return const RoomException('كود الغرفة غير صحيح.');
  }
  if (raw.contains('ROOM_NOT_FOUND')) {
    return const RoomException('لم يتم العثور على الغرفة.');
  }
  if (raw.contains('ROOM_CLOSED')) {
    return const RoomException('هذه الغرفة مغلقة.');
  }
  if (raw.contains('ROOM_FULL')) {
    return const RoomException('الغرفة ممتلئة.');
  }
  if (raw.contains('PROFILE_NOT_FOUND')) {
    return const RoomException('الملف الشخصي غير مكتمل.');
  }
  if (raw.contains('HOST_ONLY')) {
    return const RoomException('هذا الإجراء متاح للمضيف فقط.');
  }
  if (raw.contains('AUTH_REQUIRED')) {
    return const RoomException('يجب تسجيل الدخول أولاً.');
  }

  return const RoomException('حدث خطأ أثناء معالجة الغرفة.');
}
