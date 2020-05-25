import 'dart:typed_data';

import 'package:hive/hive.dart';

/// Abstract cipher can be implemented to customize encryption.
abstract class HydratedCipher implements HiveCipher {
  /// Calculate a hash of the key. Make sure to use a secure hash.
  int calculateKeyCrc();

  /// The maximum size the input can have after it has been encrypted.
  int maxEncryptedSize(Uint8List inp);

  /// Encrypt the given bytes.
  int encrypt(
      Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff);

  /// Decrypt the given bytes.
  int decrypt(
      Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff);
}

/// Default encryption algorithm. Uses AES256 CBC with PKCS7 padding.
class HydratedAesCipher extends HiveAesCipher implements HydratedCipher {
  /// Create a cipher with the given [key].
  HydratedAesCipher(List<int> key) : super(key);
}
