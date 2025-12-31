import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/File-Item-Repo/FileItemRepo.dart';

class FileItemRepoImpli implements FileItemRepo {
  final StorageService storageService;

  FileItemRepoImpli({required this.storageService});

  @override
  Future<Either<Failure, String>> uploadFile({
    required CourseFileEntity coursefileEntity,
  }) async {
    try {
      if (coursefileEntity.file == null) {
        return left(ServerFailure(message: "لم يتم اختيار ملف لرفعه"));
      }
      String url = await storageService.uploadFile(
        file: coursefileEntity.file!,
      );

      return right(url);
    } catch (e) {
      return left(
        ServerFailure(
          message:
              "حدث خطأ أثناء رفع الملف، يرجى التحقق من جودة الاتصال بالإنترنت",
        ),
      );
    }
  }
}
