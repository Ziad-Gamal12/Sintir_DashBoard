// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/FilterCoursesQueryEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseResonseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Models/CourseModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';

class CoursesrepoImpl implements Coursesrepo {
  final DataBaseService databaseservice;
  final StorageService storageService;

  CoursesrepoImpl({
    required this.databaseservice,
    required this.storageService,
  });

  @override
  Future<Either<Failure, void>> addCourse({
    required CourseEntity courseEntity,
  }) async {
    try {
      final isExists = await databaseservice.isDataExists(
        key: BackendEndpoints.coursesCollection,
        docId: courseEntity.id,
      );
      if (isExists) {
        return left(
          ServerFailure(
            message: "رمز الدورة التدريبية موجود بالفعل، يرجى اختيار رمز آخر",
          ),
        );
      }

      final data = CourseModel.fromEntity(courseEntity: courseEntity).toJson();

      await Future.wait([
        databaseservice.setData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.coursesCollection,
            docId: courseEntity.id,
          ),
          data: data,
        ),
        databaseservice.setData(
          data: data,
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.usersCollectionName,
            docId: courseEntity.contentcreaterentity!.id,
            subCollection: BackendEndpoints.coursesCollection,
            subDocId: courseEntity.id,
          ),
        ),
      ]);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(
        ServerFailure(message: "عذراً، حدث خطأ أثناء إضافة الدورة التدريبية"),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uplaodFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final url = await storageService.uploadFile(
        bytes: bytes,
        fileName: fileName,
      );
      return right(url);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(
        ServerFailure(message: "فشل رفع الملف، يرجى التأكد من اتصال الإنترنت"),
      );
    }
  }

  DocumentSnapshot? _recentLastDoc;
  DocumentSnapshot? _popularLastDoc;
  DocumentSnapshot? _myCoursesLastDoc;
  DocumentSnapshot? _teacherInterestedCoursesLastDoc;
  DocumentSnapshot? _studentInterestedCoursesLastDoc;

  Future<Either<Failure, GetCoursesResonseEntity>> _getCourses({
    required Map<String, dynamic> baseQuery,
    required FireStoreRequirmentsEntity requirements,
    required DocumentSnapshot? lastDoc,
    required bool isPaginate,
    required void Function(DocumentSnapshot?) saveLastDoc,
  }) async {
    try {
      final query = {...baseQuery};
      query["startAfter"] = isPaginate ? lastDoc : null;
      final data = await databaseservice.getData(
        query: query,
        requirements: requirements,
      );

      if (data.listData == null) {
        return right(
          GetCoursesResonseEntity(
            courses: [],
            isPaginate: isPaginate,
            hasMore: false,
          ),
        );
      }

      if (data.listData!.isNotEmpty && data.lastDocumentSnapshot != null) {
        saveLastDoc(data.lastDocumentSnapshot);
      }

      final courses = await compute(_parseCourses, data.listData!);
      return right(
        GetCoursesResonseEntity(
          isPaginate: isPaginate,
          courses: courses,
          hasMore: data.hasMore ?? false,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(ServerFailure(message: "حدث خطأ أثناء جلب قائمة الدورات"));
    }
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>> getRecentCourses({
    required bool isPaginate,
    FilterCoursesQueryEntity? filters,
  }) {
    return _getCourses(
      baseQuery: {
        "orderBy": "postedDate",
        "descending": true,
        "limit": 10,
        "searchField": "title",
        "searchValue": filters?.title,
        "filters": _buildFilters(
          filters: filters ?? FilterCoursesQueryEntity(),
        ),
      },
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
      ),
      lastDoc: _recentLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _recentLastDoc = doc,
    );
  }

  List<Map<String, dynamic>> _buildFilters({
    required FilterCoursesQueryEntity filters,
  }) {
    List<Map<String, dynamic>> filtersList = [];
    if (filters.subject != null) {
      if (filters.subject!.isNotEmpty) {
        filtersList.add({
          "field": "subject",
          "operator": "==",
          "value": filters.subject,
        });
      }
    }

    if (filters.state != null) {
      if (filters.state!.isNotEmpty) {
        filtersList.add({
          "field": "state",
          "operator": "==",
          "value": filters.state,
        });
      }
    }

    if (filters.level != null) {
      if (filters.level!.isNotEmpty) {
        filtersList.add({
          "field": "level",
          "operator": "==",
          "value": filters.level,
        });
      }
    }

    return filtersList;
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>> getPopularCourses({
    required bool isPaginate,
  }) {
    return _getCourses(
      baseQuery: {"orderBy": "studentsCount", "limit": 10},
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
      ),
      lastDoc: _popularLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _popularLastDoc = doc,
    );
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>> getMyCourses({
    required bool isPaginate,
  }) {
    return _getCourses(
      baseQuery: {"limit": 10},
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.usersCollectionName,
        docId: getUserData().uid,
        subCollection: BackendEndpoints.getCoursesfromUserDocSubCollectioName,
      ),
      lastDoc: _myCoursesLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _myCoursesLastDoc = doc,
    );
  }

  @override
  Future<Either<Failure, void>> updateCourse({
    required CourseEntity courseEntity,
  }) async {
    try {
      final data = CourseModel.fromEntity(courseEntity: courseEntity).toJson();

      await Future.wait([
        databaseservice.setData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.coursesCollection,
            docId: courseEntity.id,
          ),
          data: data,
        ),
        databaseservice.setData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.usersCollectionName,
            docId: courseEntity.contentcreaterentity!.id,
            subCollection: BackendEndpoints.coursesCollection,
            subDocId: courseEntity.id,
          ),
          data: data,
        ),
      ]);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(
        ServerFailure(message: "فشل تحديث بيانات الدورة، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>> getStudentInterestedCourses({
    required bool isPaginate,
    required String educationlevel,
  }) async {
    return _getCourses(
      baseQuery: {
        "filters": [
          {"field": "level", "operator": "==", "value": educationlevel},
          {
            "field": "state",
            "operator": "==",
            "value": BackendEndpoints.coursePublishedState,
          },
        ],
        "orderBy": "postedDate",
        "limit": 10,
      },
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
      ),
      lastDoc: _studentInterestedCoursesLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _studentInterestedCoursesLastDoc = doc,
    );
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>>
  getTeaceherInterestedCourses({
    required bool isPaginate,
    required String subject,
  }) async {
    return _getCourses(
      baseQuery: {
        "filters": [
          {"field": "subject", "operator": "==", "value": subject},
        ],
        "orderBy": "postedDate",
        "descending": true,
        "limit": 10,
      },
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
      ),
      lastDoc: _teacherInterestedCoursesLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _teacherInterestedCoursesLastDoc = doc,
    );
  }

  @override
  Future<Either<Failure, void>> deleteCourse({
    required String courseId,
    required String teacherId,
  }) async {
    try {
      Future.wait([
        databaseservice.deleteDoc(
          collectionKey: BackendEndpoints.coursesCollection,
          docId: courseId,
        ),
        databaseservice.deleteDoc(
          collectionKey: BackendEndpoints.usersCollectionName,
          docId: teacherId,
          subCollectionKey: BackendEndpoints.coursesCollection,
          subDocId: courseId,
        ),
      ]);

      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(
        ServerFailure(message: "فشل حذف الدورة، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateCourseState({
    required String courseId,
    required String newState,
    required String teacherId,
  }) async {
    try {
      Future.wait([
        databaseservice.updateData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.coursesCollection,
            docId: courseId,
          ),
          data: {"state": newState},
        ),
        databaseservice.updateData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.usersCollectionName,
            docId: teacherId,
            subCollection: BackendEndpoints.coursesCollection,
            subDocId: courseId,
          ),
          data: {"state": newState},
        ),
      ]);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (_) {
      return left(
        ServerFailure(message: "فشل تحديث حالة الدورة، يرجى المحاولة لاحقاً"),
      );
    }
  }
}

List<CourseEntity> _parseCourses(List<dynamic> listData) {
  return listData
      .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)).toEntity())
      .toList();
}
