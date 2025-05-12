import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromUtf8('0123456789abcdef0123456789abcdef');

  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encryptText(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decryptText(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
