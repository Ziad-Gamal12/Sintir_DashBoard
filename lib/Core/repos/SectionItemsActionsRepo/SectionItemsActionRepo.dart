import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/JoinedByEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';

abstract class SectionItemsActionsRepo {
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
  // SectionItemsActionsRepo
  Future<Either<Failure, void>> addJoinedBy({
    required JoinedByEntity joinedByEntity,
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  });
}
