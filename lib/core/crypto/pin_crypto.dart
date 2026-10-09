import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographic helper for PIN verification and key derivation in Pindea
class PinCrypto {
  PinCrypto._();

  /// Create a salted hash of the PIN to store as pin_verifier
  static String hashPin({required String pin, required String salt}) {
    final bytes = utf8.encode('$salt:$pin:$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a PIN against a stored verifier and salt
  static bool verifyPin({
    required String pin,
    required String salt,
    required String verifier,
  }) {
    final computed = hashPin(pin: pin, salt: salt);
    return computed == verifier;
  }

  /// Derive a 256-bit encryption key string from PIN and salt (for optional SQLCipher encryption)
  static String deriveKey({required String pin, required String salt}) {
    final firstPass = sha256.convert(utf8.encode('pindea_key:$pin:$salt')).bytes;
    final secondPass = sha256.convert(firstPass);
    return secondPass.toString();
  }
}
