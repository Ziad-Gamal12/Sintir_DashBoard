// ignore_for_file: file_names, camel_case_types

import 'package:hive_flutter/hive_flutter.dart';

abstract class Hive_Services {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('app_storage');
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
}
