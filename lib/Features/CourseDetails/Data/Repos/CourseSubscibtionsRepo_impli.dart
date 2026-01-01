// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSubscribersEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Models/SubscriberModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart'; // for compute

class CourseSubscriptionsRepoImpl implements CourseSubscibtionsRepo {
  final DataBaseService databaseService;

  CourseSubscriptionsRepoImpl({required this.databaseService});

  @override
  Future<Either<Failure, bool>> checkIfSubscribed({
    required String userID,
    required String courseID,
  }) async {
    try {
      final isSubscribed = await databaseService.isDataExists(
        key: BackendEndpoints.usersCollectionName,
        subCollectionKey: BackendEndpoints.checkifSubscribedSubCollection,
        docId: userID,
        subDocId: courseID,
      );
      return right(isSubscribed);
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  /// ============= Subscribers Pagination =============

  DocumentSnapshot? _lastSubscribersDoc;
  final Map<String, dynamic> _baseQuery = {"startAfter": null, "limit": 10};

  @override
  Future<Either<Failure, GetCourseSubscribersEntity>> getSubscribers({
    required String courseID,
    required bool isPaginate,
  }) async {
    try {
      final query = Map<String, dynamic>.from(_baseQuery)
        ..["startAfter"] = isPaginate ? _lastSubscribersDoc : null;

      final response = await databaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          subCollection: BackendEndpoints.subscribersSubCollection,
          docId: courseID,
        ),
        query: query,
      );

      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد بيانات"));
      }

      if (response.listData!.isEmpty) {
        return right(
          GetCourseSubscribersEntity(
            subscribers: [],
            hasMore: false,
            isPaginate: isPaginate,
          ),
        );
      }

      _lastSubscribersDoc = response.lastDocumentSnapshot;

      final subscribers = await compute(_parseSubscribers, response.listData!);
      final hasMore = response.hasMore ?? false;

      return right(
        GetCourseSubscribersEntity(
          subscribers: subscribers,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getSubscribersCount({
    required String courseID,
  }) async {
    try {
      final response = await databaseService.getCollectionItemsCount(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseID,
          subCollection: BackendEndpoints.subscribersSubCollection,
        ),
      );
      return right(response);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, GetCourseSubscribersEntity>> searchSubscribers({
    required String courseID,
    required String searchKey,
    required bool isPaginate,
  }) async {
    try {
      Map<String, dynamic> query = {
        "startAfter": isPaginate ? _lastSubscribersDoc : null,
        "limit": 10,
        "searchField": "name",
        "searchValue": searchKey,
      };

      final response = await databaseService.getData(
        query: query,
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          subCollection: BackendEndpoints.subscribersSubCollection,
          docId: courseID,
        ),
      );

      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد بيانات"));
      }

      if (response.listData!.isEmpty) {
        return right(
          GetCourseSubscribersEntity(
            subscribers: [],
            hasMore: false,
            isPaginate: isPaginate,
          ),
        );
      }

      _lastSubscribersDoc = response.lastDocumentSnapshot;

      final subscribers = await compute(_parseSubscribers, response.listData!);
      final hasMore = response.hasMore ?? false;

      return right(
        GetCourseSubscribersEntity(
          subscribers: subscribers,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }
}

List<SubscriberEntity> _parseSubscribers(List<dynamic> rawList) {
  return rawList.map((e) => SubscriberModel.fromJson(e).toEntity()).toList();
}
