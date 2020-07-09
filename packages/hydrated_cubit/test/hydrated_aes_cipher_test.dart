import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_cubit/hydrated_cubit.dart';

void main() {
  group('HydratedAesCipher', () {
    const password = 'hydration';
    final bytes = sha256.convert(utf8.encode(password)).bytes;
    test('creates an instance', () {
      expect(HydratedAesCipher(bytes), isNotNull);
    });

    test('is a HiveAesCipher', () {
      expect(HydratedAesCipher(bytes), isA<HiveAesCipher>());
    });
  });
}
