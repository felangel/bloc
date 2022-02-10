library crypto_api;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// {@template crypto_api}
/// A crypto API with common encryption methods.
/// {@endtemplate}
class CryptoApi {
  /// {@macro crypto_api}
  CryptoApi({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// Set of characters used to generate encrypted values.
  static const _charset =
      '''0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._''';

  /// Generates a cryptographically secure random nonce,
  /// to be included in a credential request.
  String generateNonce([int length = 32]) {
    return List.generate(
      length,
      (_) => _charset[_random.nextInt(_charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
