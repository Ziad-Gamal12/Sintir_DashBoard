// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSectionsResonseEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';

abstract class CourseSectionsRepo {
  Future<Either<Failure, void>> addCourseSection({
    required CourseSectionEntity section,
    required String courseId,
  });

  Future<Either<Failure, GetCourseSectionsResonseEntity>> getCourseSections({
    required String courseId,
    required bool isPaginate,
  });
  // SectionItemsActionsRepo
  Future<Either<Failure, void>> addSectionItem({
    required sectionItem,
    required String courseId,
    required String sectionId,
  });
  // SectionItemsActionsRepo
  Future<Either<Failure, List>> getSectionsItems({
    required String courseId,
    required String sectionId,
  });
  Future<Either<Failure, void>> deleteSection({
    required String courseId,
    required String sectionId,
  });
  Future<Either<Failure, void>> deleteSectionItem({
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  });
}
