// ignore_for_file: file_names

import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';

abstract class DataBaseService {
  Future<void> setData({
    required Map<String, dynamic> data,
    required FireStoreRequirmentsEntity requirements,
  });
  Future<FireStoreResponse> getData({
    required FireStoreRequirmentsEntity requirements,
    Map<String, dynamic>? query,
  });
  Future<bool> isDataExists({
    required String key,
    required String docId,
    String? subCollectionKey,
    String? subDocId,
  });
  Future<bool> isFeildExists({
    required String key,
    required String feild,
    required String feildValue,
  });

  Future<void> updateData({
    required dynamic data,
    required FireStoreRequirmentsEntity requirements,
    String? field,
  });
  Future<void> deleteDoc({
    required String collectionKey,
    required String docId,
    String? subCollectionKey,
    String? subDocId,
    String? subCollectionKey2,
    String? subDocId2,
  });
  Future<int> getCollectionItemsCount({
    required FireStoreRequirmentsEntity requirements,
    Map<String, dynamic>? query,
  });
}
