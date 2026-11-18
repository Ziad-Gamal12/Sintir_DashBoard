// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseFeedBacksResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/ReviewReportEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Services/EdgeFunctionClient.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Models/CourseFedBacksModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';

class CourseFeedBacksRepoImpli implements CourseFeedBacksRepo {
  final DataBaseService databaseservice;
  final EdgeFunctionClient edgeFunctions;

  CourseFeedBacksRepoImpli({
    required this.databaseservice,
    EdgeFunctionClient? edgeFunctions,
  }) : edgeFunctions = edgeFunctions ?? EdgeFunctionClient();

  static const String reviewReportsCollection = "ReviewReports";

  @override
  Future<Either<Failure, void>> addCourseFedBack({
    required String courseId,
    required CoursefeedbackItemEntity review,
  }) async {
    try {
      final Map<String, dynamic> json = Coursefeedbacksmodel.fromEntity(
        coursefedbackItemEntity: review,
      ).toJson();

      await databaseservice.setData(
        data: json,
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.feedBacksSubCollection,
          subDocId: review.uid,
        ),
      );

      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "حدث خطأ ما يرجى المحاولة وقت أخر"));
    }
  }

  DocumentSnapshot? _getCourseFeedBacksLastDoc;

  final Map<String, dynamic> _baseGetCourseFeedBacksQuery = {
    "startAfter": null,
    "limit": 10,
  };

  @override
  Future<Either<Failure, GetCourseFeedBacksResponseEntity>> getCourseFedBacks({
    required String courseId,
    required bool isPaginate,
  }) async {
    try {
      final Map<String, dynamic> query = Map<String, dynamic>.from(
        _baseGetCourseFeedBacksQuery,
      );
      query["startAfter"] = isPaginate == true
          ? _getCourseFeedBacksLastDoc
          : null;
      final FireStoreResponse response = await databaseservice.getData(
        query: query,
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.feedBacksSubCollection,
        ),
      );

      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد بيانات"));
      }
      if (response.listData!.isEmpty) {
        return right(
          GetCourseFeedBacksResponseEntity(
            feedBacks: [],
            hasMore: false,
            isPaginate: isPaginate,
          ),
        );
      }

      if (response.lastDocumentSnapshot != null) {
        _getCourseFeedBacksLastDoc = response.lastDocumentSnapshot;
      }
      final List<CoursefeedbackItemEntity> courseReviews =
          await compute<
            List<Map<String, dynamic>>,
            List<CoursefeedbackItemEntity>
          >(
            _parseCourseFeedbacks,
            response.listData as List<Map<String, dynamic>>,
          );

      final bool hasMore = response.hasMore ?? false;

      return right(
        GetCourseFeedBacksResponseEntity(
          feedBacks: courseReviews,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "حدث خطأ ما يرجى المحاولة وقت أخر"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourseFedBack({
    required String courseId,
    required String feedBackId,
  }) async {
    try {
      await edgeFunctions.invoke('delete-course-feedback', {
        'courseId': courseId,
        'feedbackUid': feedBackId,
      });
      final reports = await getOpenReviewReports(courseId: courseId);
      final open = reports.fold(
        (_) => const <ReviewReportEntity>[],
        (byReview) => byReview[feedBackId] ?? const <ReviewReportEntity>[],
      );
      if (open.isNotEmpty) {
        await closeReviewReports(reports: open, status: 'review_removed');
      }
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "حدث خطأ ما يرجى المحاولة وقت أخر"));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<ReviewReportEntity>>>>
  getOpenReviewReports({required String courseId}) async {
    try {
      final response = await databaseservice.getData(
        query: {
          "filters": <Map<String, dynamic>>[
            {"field": "courseId", "value": courseId},
            {"field": "status", "value": "open"},
          ],
          "limit": 200,
        },
        requirements: FireStoreRequirmentsEntity(
          collection: reviewReportsCollection,
        ),
      );
      final rows = (response.listData ?? const [])
          .whereType<Map<String, dynamic>>();
      return right(ReviewReportEntity.groupByReview(rows));
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "تعذر تحميل البلاغات"));
    }
  }

  @override
  Future<Either<Failure, void>> closeReviewReports({
    required List<ReviewReportEntity> reports,
    required String status,
  }) async {
    try {
      final reviewer = getUserData().uid;
      await Future.wait([
        for (final report in reports)
          databaseservice.updateData(
            requirements: FireStoreRequirmentsEntity(
              collection: reviewReportsCollection,
              docId: report.id,
            ),
            data: {
              'status': status,
              'resolvedBy': reviewer,
              'resolvedAt': FieldValue.serverTimestamp(),
            },
          ),
      ]);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "تعذر تحديث البلاغات"));
    }
  }
}

List<CoursefeedbackItemEntity> _parseCourseFeedbacks(
  List<Map<String, dynamic>> rawList,
) {
  final List<CoursefeedbackItemEntity> results = [];
  for (final Map<String, dynamic> item in rawList) {
    try {
      final CoursefeedbackItemEntity entity = Coursefeedbacksmodel.fromJson(
        item,
      ).toEntity();
      results.add(entity);
    } catch (e) {
      throw CustomException(message: "حدث خطأ ما يرجى المحاولة وقت أخر");
    }
  }
  return results;
}
