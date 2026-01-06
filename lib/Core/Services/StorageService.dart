import 'dart:typed_data';

abstract class StorageService {
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
  });
  Future<void> deleteFile({required String url});
}
