import 'package:image_picker/image_picker.dart';
import 'package:sintir_dashboard/Core/Entities/imagePickerResult.dart';

abstract class PickerAssetsInterface {
  Future<ImagePickerResult> pickMultiImages();

  Future<dynamic> getVideo({required ImageSource source});
}
