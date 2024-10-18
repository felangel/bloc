import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:test/test.dart';

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
