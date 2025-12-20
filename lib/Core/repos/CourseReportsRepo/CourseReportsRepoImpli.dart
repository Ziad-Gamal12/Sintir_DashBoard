// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseReportsResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Models/CoursereportsitemModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Core/repos/CourseReportsRepo/CourseReportsRepo.dart';

class CourseReportsRepoimpli implements CourseReportsRepo {
  final DataBaseService databaseservice;
  CourseReportsRepoimpli({required this.databaseservice});

  @override
  Future<Either<Failure, void>> addCourseReport({
    required String courseId,
    required CourseReportEntity reportEntity,
  }) async {
    try {
      final json = CoursereportsitemModel.fromEntity(
        courseReportsItemEntity: reportEntity,
      ).toJson();
      await databaseservice.setData(
        data: json,
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.reportsSubCollection,
        ),
      );
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(
          message: "حدث خطأ أثناء إرسال البلاغ، يرجى المحاولة مرة أخرى",
        ),
      );
    }
  }

  DocumentSnapshot? _lastDoc;

  final Map<String, dynamic> _baseQuery = {
    "startAfter": null,
    "orderBy": "date",
    "limit": 10,
  };

  @override
  Future<Either<Failure, GetCourseReportsResponseEntity>> getCourseReports({
    required String courseId,
    required bool isPaginate,
  }) async {
    try {
      _baseQuery["startAfter"] = isPaginate ? _lastDoc : null;
      final response = await databaseservice.getData(
        query: _baseQuery,
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.reportsSubCollection,
        ),
      );
      if (response.listData == null) {
        return left(ServerFailure(message: "لا توجد بلاغات مسجلة لهذه الدورة"));
      }
      if (response.listData!.isEmpty) {
        return right(
          GetCourseReportsResponseEntity(
            reports: [],
            hasMore: false,
            isPaginate: isPaginate,
          ),
        );
      }
      if (response.lastDocumentSnapshot != null) {
        _lastDoc = response.lastDocumentSnapshot;
      }
      final reports = await compute(
        _mapReports,
        response.listData as List<Map<String, dynamic>>,
      );
      final hasMore = response.hasMore ?? false;
      return right(
        GetCourseReportsResponseEntity(
          reports: reports,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "فشل تحميل التقارير، تأكد من اتصالك بالإنترنت"),
      );
    }
  }
}

List<CourseReportEntity> _mapReports(List<Map<String, dynamic>> data) {
  return data
      .map((e) => CoursereportsitemModel.fromJson(e).toEntity())
      .toList();
}
