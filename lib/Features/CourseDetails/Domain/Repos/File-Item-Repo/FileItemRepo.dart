import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';

abstract class FileItemRepo {
  Future<Either<Failure, String>> uploadFile({
    required CourseFileEntity coursefileEntity,
  });
}
