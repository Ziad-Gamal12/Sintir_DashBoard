// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseResonseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Models/CourseModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
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

      final data = Coursemodel.fromEntity(courseEntity: courseEntity).toJson();

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
  Future<Either<Failure, String>> uplaodFile({required File file}) async {
    try {
      final url = await storageService.uploadFile(file: file);
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
  }) {
    return _getCourses(
      baseQuery: {
        "filters": [
          {
            "field": "state",
            "operator": "==",
            "value": BackendEndpoints.coursePublishedState,
          },
        ],
        "orderBy": "postedDate",
        "descending": true,
        "limit": 10,
      },
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
      ),
      lastDoc: _recentLastDoc,
      isPaginate: isPaginate,
      saveLastDoc: (doc) => _recentLastDoc = doc,
    );
  }

  @override
  Future<Either<Failure, GetCoursesResonseEntity>> getPopularCourses({
    required bool isPaginate,
  }) {
    return _getCourses(
      baseQuery: {
        "filters": [
          {
            "field": "state",
            "operator": "==",
            "value": BackendEndpoints.coursePublishedState,
          },
        ],
        "orderBy": "studentsCount",
        "limit": 10,
      },
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
      final data = Coursemodel.fromEntity(courseEntity: courseEntity).toJson();

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
          {
            "field": "state",
            "operator": "==",
            "value": BackendEndpoints.coursePublishedState,
          },
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
}

List<CourseEntity> _parseCourses(List<dynamic> listData) {
  return listData
      .map((e) => Coursemodel.fromJson(Map<String, dynamic>.from(e)).toEntity())
      .toList();
}
