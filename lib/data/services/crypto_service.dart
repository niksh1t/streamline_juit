// lib/services/crypto_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CryptoService {
  // Fixed IV from the JavaScript source
  static final _iv = encrypt.IV.fromUtf8("dcek9wb8frty1pnm");

  // --- 1. Key Generation ---
  Uint8List generateDailyKey() {
    final now = DateTime.now();
    final dd = DateFormat('dd').format(now);
    final mm = DateFormat('MM').format(now);
    final yy = DateFormat('yy').format(now);

    // JS getDay(): Sun=0, Mon=1, ..., Sat=6
    // Dart weekday: Mon=1, ..., Sun=7
    // Conversion: (dartWeekday % 7) gives the JS value
    final w = (now.weekday % 7).toString();

    final keyString = "qa8y${dd[0]}${mm[0]}${yy[0]}$w${dd[1]}${mm[1]}${yy[1]}ty1pn";
    if (kDebugMode) {
      print("🔑 Generated Daily Key String: $keyString");
    }
    return utf8.encode(keyString);
  }

  // --- 2. "localname" Generation ---
  Uint8List _generateLocalNameRawBytes() {
    const chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
    final random = Random.secure();
    final randomString = String.fromCharCodes(
      Iterable.generate(9, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    final prefix = randomString.substring(0, 4);
    final suffix = randomString.substring(4, 9);

    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);
    final dayOfWeekJs = (now.weekday % 7).toString();

    final dateString = "${day[0]}${month[0]}${year[0]}$dayOfWeekJs${day[1]}${month[1]}${year[1]}";
    final combinedString = "$prefix$dateString$suffix";
    
    if (kDebugMode) {
      print("📦 Generated LocalName Raw String: $combinedString");
    }
    return utf8.encode(combinedString);
  }

  // --- 3. AES Encryption ---
  String encryptPayload(Uint8List payloadBytes, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

    final encrypted = encrypter.encryptBytes(payloadBytes, iv: _iv);
    if (kDebugMode) {
      print("🔒 Payload encrypted successfully.");
    }
    return encrypted.base64;
  }
  
  // --- 4. Helper to combine generation and encryption of "localname" ---
  String generateEncryptedLocalName() {
    if (kDebugMode) {
      print("\n--- Generating Encrypted 'localname' ---");
    }
    final key = generateDailyKey();
    final rawBytes = _generateLocalNameRawBytes();
    final encrypted = encryptPayload(rawBytes, key);
    if (kDebugMode) {
      print("✅ Encrypted 'localname': $encrypted");
    }
    return encrypted;
  }
}