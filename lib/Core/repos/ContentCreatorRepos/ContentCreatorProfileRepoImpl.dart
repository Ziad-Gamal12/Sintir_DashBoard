import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Models/CourseModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';

class ContentCreatorProfileRepoImpl implements ContentCreatorProfileRepo {
  final DataBaseService dataBaseService;

  ContentCreatorProfileRepoImpl({required this.dataBaseService});
  @override
  Future<Either<Failure, List<CourseEntity>>> getContentCreatorCourses({
    required String userId,
  }) async {
    try {
      Map<String, dynamic> query = {
        "orderBy": "studentsCount",
        "filters": <Map<String, dynamic>>[
          {
            "field": "contentcreaterentity.id",
            "operator": "==",
            "value": userId,
          },
        ],
      };
      final response = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
        ),
        query: query,
      );
      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد دورات"));
      }
      final List<Map<String, dynamic>> data =
          response.listData! as List<Map<String, dynamic>>;
      List<CourseEntity> courses = data
          .map((e) => CourseModel.fromJson(e).toEntity())
          .toList();
      return right(courses);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> searchContentCreatorCourses({
    required String userId,
    required String keyword,
  }) async {
    try {
      Map<String, dynamic> query = {
        "orderBy": "studentsCount",
        "searchField": "title",
        "searchValue": keyword,
        "filters": <Map<String, dynamic>>[
          {
            "field": "contentcreaterentity.id",
            "operator": "==",
            "value": userId,
          },
        ],
      };
      final response = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
        ),
        query: query,
      );
      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد دورات"));
      }
      final List<Map<String, dynamic>> data =
          response.listData! as List<Map<String, dynamic>>;
      List<CourseEntity> courses = data
          .map((e) => CourseModel.fromJson(e).toEntity())
          .toList();
      return right(courses);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
