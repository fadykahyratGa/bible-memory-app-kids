import 'dart:math';

class RoomCodeHelper {
  RoomCodeHelper._();

  static const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final RegExp _pattern = RegExp(r'^[A-Z2-9]{5,6}$');

  static String generate({int length = 6, Random? random}) {
    if (length != 5 && length != 6) {
      throw ArgumentError.value(length, 'length', 'Room code length must be 5 or 6');
    }
    final source = random ?? Random.secure();
    return List<String>.generate(length, (_) => alphabet[source.nextInt(alphabet.length)]).join();
  }

  static bool isValid(String value) {
    return _pattern.hasMatch(value.trim().toUpperCase());
  }
}
