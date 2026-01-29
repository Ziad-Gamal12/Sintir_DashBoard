// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseFeedBacksResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Models/CourseFedBacksModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';

class CourseFeedBacksRepoImpli implements CourseFeedBacksRepo {
  final DataBaseService databaseservice;

  CourseFeedBacksRepoImpli({required this.databaseservice});

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
      await databaseservice.deleteDoc(
        collectionKey: BackendEndpoints.coursesCollection,
        docId: courseId,
        subCollectionKey: BackendEndpoints.feedBacksSubCollection,
        subDocId: feedBackId,
      );
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: "حدث خطأ ما يرجى المحاولة وقت أخر"));
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
