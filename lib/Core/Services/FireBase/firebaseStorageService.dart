// ignore_for_file: camel_case_types, depend_on_referenced_packages, file_names, await_only_futures

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';

class FireBaseStorageService implements StorageService {
  final storage = FirebaseStorage.instance;
  final PickerAssetsInterface pickerassetsservice;

  FireBaseStorageService({required this.pickerassetsservice});

  @override
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      var ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/png'),
      );
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      // Logging the error is helpful for debugging
      throw CustomException(message: "حدث خطأ فى رفع الملف");
    }
  }

  @override
  Future<void> deleteFile({required String url}) async {
    try {
      await storage.refFromURL(url).delete();
    } catch (e) {
      throw CustomException(message: "حدث خطأ أثناء حذف الملف");
    }
  }
}
