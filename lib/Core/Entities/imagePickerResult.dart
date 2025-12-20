// ignore_for_file: camel_case_types, file_names

import 'dart:io';
import 'dart:typed_data';

class ImagePickerResult {
  List<File>? files;
  List<Uint8List>? bytes;
  final List<String> fileNames;
  ImagePickerResult({this.files, this.bytes, required this.fileNames});
}
