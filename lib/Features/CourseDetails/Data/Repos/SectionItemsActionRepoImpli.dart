// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/JoinedByEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Models/FileItemModels/CoursefileModel.dart';
import 'package:sintir_dashboard/Core/Models/JoinedByModel.dart';
import 'package:sintir_dashboard/Core/Models/TestItemModels/CourseTestModel.dart';
import 'package:sintir_dashboard/Core/Models/VideoItemModels/CoursevedioitemModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/SectionItemsActionsRepo/SectionItemsActionRepo.dart';

class SectionItemsActionsRepoImpli implements SectionItemsActionsRepo {
  final DataBaseService datebaseservice;

  SectionItemsActionsRepoImpli({required this.datebaseservice});

  @override
  Future<Either<Failure, void>> addSectionItem({
    required sectionItem,
    required String courseId,
    required String sectionId,
  }) async {
    try {
      FireStoreRequirmentsEntity requirements(String itemId) =>
          FireStoreRequirmentsEntity(
            collection: BackendEndpoints.coursesCollection,
            docId: courseId,
            subCollection: BackendEndpoints.sectionsSubCollection,
            subDocId: sectionId,
            subCollection2: BackendEndpoints.sectionItemsSubCollection,
            sub2DocId: itemId,
          );

      if (sectionItem is CourseTestEntity) {
        final json = Coursetestmodel.fromEntity(sectionItem).toJson();
        await datebaseservice.setData(
          requirements: requirements(sectionItem.id),
          data: json,
        );
        return right(null);
      } else if (sectionItem is CourseVideoItemEntity) {
        final json = CourseVideoItemModel.fromEntity(sectionItem).toJson();
        await datebaseservice.setData(
          requirements: requirements(sectionItem.id),
          data: json,
        );
        return right(null);
      } else if (sectionItem is CourseFileEntity) {
        final json = Coursefilemodel.fromEntity(sectionItem).toJson();
        await datebaseservice.setData(
          requirements: requirements(sectionItem.id),
          data: json,
        );
        return right(null);
      } else {
        return left(
          ServerFailure(message: "نوع العنصر غير معروف، لا يمكن إضافته"),
        );
      }
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ غير متوقع أثناء إضافة محتوى القسم"),
      );
    }
  }

  @override
  Future<Either<Failure, List>> getSectionsItems({
    required String courseId,
    required String sectionId,
  }) async {
    try {
      List items = [];
      FireStoreResponse data = await datebaseservice.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.sectionsSubCollection,
          subDocId: sectionId,
          subCollection2: BackendEndpoints.sectionItemsSubCollection,
        ),
      );

      if (data.listData == null) {
        return left(
          ServerFailure(message: "لم يتم العثور على محتوى لهذا القسم"),
        );
      }

      if (data.listData!.isEmpty) {
        return right([]);
      }

      for (var item in data.listData!) {
        if (item["type"] == "Test") {
          items.add(Coursetestmodel.fromJson(item).toEntity());
        } else if (item["type"] == "Vedio") {
          items.add(CourseVideoItemModel.fromJson(item).toEntity());
        } else {
          items.add(Coursefilemodel.fromJson(item).toEntity());
        }
      }
      return right(items);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(
          message: "فشل تحميل محتويات القسم، يرجى المحاولة مرة أخرى",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addJoinedBy({
    required JoinedByEntity joinedByEntity,
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  }) async {
    try {
      Map<String, dynamic> json = JoinedbyModel.fromEntity(
        joinedByEntity,
      ).toJson();
      await datebaseservice.setData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.sectionsSubCollection,
          subDocId: sectionId,
          subCollection2: BackendEndpoints.sectionItemsSubCollection,
          sub2DocId: sectionItemId,
          subCollection3: BackendEndpoints.joinedBySubCollection,
          sub3DocId: joinedByEntity.uid,
        ),
        data: json,
      );
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ أثناء تسجيل بيانات المشاهدة/الانضمام"),
      );
    }
  }
}
