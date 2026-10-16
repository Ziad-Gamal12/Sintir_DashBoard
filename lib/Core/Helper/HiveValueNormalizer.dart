import 'package:cloud_firestore/cloud_firestore.dart';

class HiveValueNormalizer {
  static dynamic normalize(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): normalize(entry.value),
      };
    }

    if (value is List) {
      return value.map(normalize).toList();
    }

    return value;
  }
}
