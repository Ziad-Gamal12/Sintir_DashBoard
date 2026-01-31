import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:sintir_dashboard/Core/Entities/imagePickerResult.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';

class PickerAssetsService implements PickerAssetsInterface {
  @override
  Future<ImagePickerResult> pickMultiImages() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true
      ..click();
    final completer = Completer<ImagePickerResult>();
    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        completer.completeError(CustomException(message: "لا يمكن التحميل"));
        throw CustomException(message: "لا يمكن التحميل");
      }
      List<Future<Uint8List>> readFutures = [];
      List<String> fileNames = [];
      for (var file in files) {
        fileNames.add(file.name);
        final reader = html.FileReader();
        final fileCompleter = Completer<Uint8List>();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          fileCompleter.complete(reader.result as Uint8List);
        });

        readFutures.add(fileCompleter.future);
      }

      final bytesList = await Future.wait(readFutures);

      completer.complete(
        ImagePickerResult(bytes: bytesList, fileNames: fileNames),
      );
    });

    return completer.future;
  }

  @override
  Future<dynamic> getVideo({required ImageSource source}) async {
    return null;
  }
}
