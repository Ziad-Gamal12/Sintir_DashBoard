// ignore_for_file: file_names

import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:sintir_dashboard/Core/Entities/imagePickerResult.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';

class PickerAssetsService implements PickerAssetsInterface {
  final ImagePicker picker = ImagePicker();

  @override
  Future<ImagePickerResult> pickMultiImages() async {
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    List<File> files = [];
    List<String> fileNames = [];
    for (var xfile in pickedFiles) {
      files.add(io.File(xfile.path));
      fileNames.add(xfile.name);
    }
    return ImagePickerResult(files: files, fileNames: fileNames);
  }

  @override
  Future<dynamic> getVideo({required ImageSource source}) async {
    final XFile? pickedFile = await picker.pickVideo(source: source);
    if (pickedFile == null) return null;
    return io.File(pickedFile.path);
  }
}
