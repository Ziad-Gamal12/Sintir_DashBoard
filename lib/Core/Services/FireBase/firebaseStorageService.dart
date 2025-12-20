// ignore_for_file: camel_case_types, depend_on_referenced_packages, file_names, await_only_futures

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';

class FireBaseStorageService implements StorageService {
  final storage = FirebaseStorage.instance;
  final PickerAssetsInterface pickerassetsservice;
  FireBaseStorageService({required this.pickerassetsservice});
  @override
  Future<String> uploadFile({required File file}) async {
    try {
      String filePath = basename(file.path);
      var ref = storage.ref(filePath);
      String url = await ref
          .putFile(file)
          .then((p0) => p0.ref.getDownloadURL());
      return url;
    } catch (e) {
      throw CustomException(message: "حدث خطأ فى رفع الملف");
    }
  }

  @override
  Future<void> deleteFile({required String url}) async {
    await storage.refFromURL(url).delete();
  }
}
