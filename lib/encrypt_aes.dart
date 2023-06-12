import 'package:encrypt/encrypt.dart';

class EncryptData{
//for AES Algorithms

  static Encrypted? encrypted;
  static var decrypted;


  String encryptAES(plainText){
    final key = Key.fromUtf8('mohammedizzmohammedizzmohammediz');
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted!.base64;
  }

  String decryptAES(plainText){
    final key = Key.fromUtf8('mohammedizzmohammedizzmohammediz');
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    decrypted = encrypter.decrypt(Encrypted.fromBase64(plainText), iv: iv);
    return decrypted;
  }


  String encryptSalsa(plainText){
    final key = Key.fromLength(32);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(Salsa20(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decryptSalsa(plainText){
    final key = Key.fromLength(32);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(Salsa20(key));
    decrypted = encrypter.decrypt(Encrypted.fromBase64(plainText), iv: iv);
    return decrypted;
  }
}