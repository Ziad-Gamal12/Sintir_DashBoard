import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';

abstract class FileItemRepo {
  Future<Either<Failure, String>> uploadFile({
    required CourseFileEntity coursefileEntity,
  });
}
