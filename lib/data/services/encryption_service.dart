import 'package:encrypt/encrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // Hardcoded app-level key (32 bytes) - best-effort obfuscation
  static const String _keyHex = 'e8b8c8d8e8f808182838485868788898a8b8c8d8e8f808182838485868788898';
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  void initialize() {
    final keyBytes = utf8.encode(_keyHex).sublist(0, 32);
    _key = Key(Uint8List.fromList(keyBytes));
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  String encrypt(String plaintext) {
    final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String ciphertext) {
    try {
      final decrypted = _encrypter.decrypt64(ciphertext, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }

  bool isVolunteerDevice() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null || session.isExpired) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
