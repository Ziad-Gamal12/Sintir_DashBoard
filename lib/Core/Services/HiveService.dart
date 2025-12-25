// ignore_for_file: file_names, camel_case_types

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class Hive_Services {
  static late Box _box;

  static Future<void> init() async {
    const secureStorage = FlutterSecureStorage();

    // 1. Check if we already have an encryption key
    var containsEncryptionKey = await secureStorage.containsKey(
      key: 'encryptionKey',
    );
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'encryptionKey',
        value: base64UrlEncode(key),
      );
    }

    // 3. Read the key
    var encryptionKeyString = await secureStorage.read(key: 'encryptionKey');
    var encryptionKeyUint8List = base64Url.decode(encryptionKeyString!);

    // 4. Open the box with the encryption key
    _box = await Hive.openBox(
      'app_storage',
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );
  }

  static Future<void> boolSetter({
    required String key,
    required bool value,
  }) async {
    await _box.put(key, value);
  }

  static bool boolGetter({required String key}) {
    return _box.get(key, defaultValue: false);
  }

  static Future<void> stringSetter({
    required String key,
    required String value,
  }) async {
    await _box.put(key, value);
  }

  static String stringGetter({required String key}) {
    return _box.get(key, defaultValue: "");
  }

  static Future<void> jsonSetter({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    await _box.put(key, value);
  }

  static Map<String, dynamic> jsonGetter({required String key}) {
    final data = _box.get(key);
    if (data == null) return {};

    return _deepConvert(data) as Map<String, dynamic>;
  }

  static dynamic _deepConvert(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _deepConvert(v)));
    } else if (value is List) {
      return value.map((item) => _deepConvert(item)).toList();
    }
    return value;
  }
}
