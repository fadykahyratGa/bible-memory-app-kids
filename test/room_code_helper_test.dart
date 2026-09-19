import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:bible_memory_app_kids/features/rooms/domain/room_code.dart';

void main() {
  group('RoomCodeHelper', () {
    test('generates six-character uppercase code from allowed alphabet', () {
      final code = RoomCodeHelper.generate(random: Random(1));
      expect(code.length, 6);
      expect(RoomCodeHelper.isValid(code), isTrue);
      expect(code.contains('0'), isFalse);
      expect(code.contains('1'), isFalse);
      expect(code.contains('O'), isFalse);
      expect(code.contains('I'), isFalse);
    });

    test('rejects unsupported generated code lengths at runtime', () {
      expect(() => RoomCodeHelper.generate(length: 4), throwsArgumentError);
      expect(() => RoomCodeHelper.generate(length: 7), throwsArgumentError);
    });

    test('validates only 5 or 6 codes using A-Z and digits 2-9', () {
      expect(RoomCodeHelper.isValid('ABCD2'), isTrue);
      expect(RoomCodeHelper.isValid('ABCDEF'), isTrue);
      expect(RoomCodeHelper.isValid('ABC2D9'), isTrue);
      expect(RoomCodeHelper.isValid('abc12'), isFalse);
      expect(RoomCodeHelper.isValid('AB1'), isFalse);
      expect(RoomCodeHelper.isValid('ABCD@1'), isFalse);
      expect(RoomCodeHelper.isValid('ABCDO1'), isFalse);
      expect(RoomCodeHelper.isValid('ABCD01'), isFalse);
      expect(RoomCodeHelper.isValid(' ABCD2 '), isTrue);
    });
  });
}
