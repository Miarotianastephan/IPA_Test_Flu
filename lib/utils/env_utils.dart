import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pointycastle/export.dart';

String decryptDomain(String encryptedData) {
  try {
    final parts = encryptedData.split(':');

    final iv = Uint8List.fromList(hex.decode(parts[0]));

    final encryptedBytes = Uint8List.fromList(hex.decode(parts[1]));

    final scrypt = Scrypt();
    scrypt.init(
      ScryptParameters(
        16384,
        8,
        1,
        32,
        Uint8List.fromList(utf8.encode('salt')),
      ),
    );

    final key = scrypt.process(
      Uint8List.fromList(
        utf8.encode(
          dotenv.env['URLS_JSON_ENCRYPTION_KEY'] ??
              "default-key-change-in-production-32",
        ),
      ),
    );

    final cipher = CBCBlockCipher(AESEngine());
    cipher.init(false, ParametersWithIV(KeyParameter(key), iv));
    final paddedPlainText = Uint8List(encryptedBytes.length);
    var offset = 0;
    while (offset < encryptedBytes.length) {
      offset += cipher.processBlock(
        encryptedBytes,
        offset,
        paddedPlainText,
        offset,
      );
    }

    final padCount = paddedPlainText.last;
    final plainText = paddedPlainText.sublist(
      0,
      paddedPlainText.length - padCount,
    );
    return utf8.decode(plainText);
  } catch (e) {
    debugPrint('[DebugDomain] Decryption error: $e');
    throw Exception('Decryption failed: $e');
  }
}
