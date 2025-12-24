// ignore_for_file: file_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSubscribersEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Models/CourseModel.dart';
import 'package:sintir_dashboard/Core/Models/Transactions/TransactionModel.dart';
import 'package:sintir_dashboard/Core/Models/subscripersModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Core/repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class CourseSubscriptionsRepoImpl implements CourseSubscibtionsRepo {
  final DataBaseService databaseService;

  CourseSubscriptionsRepoImpl({required this.databaseService});

  @override
  Future<Either<Failure, void>> subscribeToCourse({
    required CourseEntity course,
    required UserEntity userEntity,
    required String transactionId,
    required TransactionEntity transactionEntity,
    required double amount,
  }) async {
    try {
      final subscriber = _buildSubscriberEntity(userEntity);

      await Future.wait([
        _addCourseToUserList(course, userEntity),
        _addSubscriber(
          subscriber,
          _buildSubscriberReq(course.id, userEntity.uid),
        ),
        _updateCourseSubscriberCount(courseId: course.id),
        _updateTeacherWalletBatch(
          teacherId: course.contentcreaterentity?.id ?? "",
          amount: amount,
          transactionId: transactionId,
        ),
        storeSubscribtionTransaction(
          courseID: course.id,
          userID: userEntity.uid,
          transaction: transactionEntity,
        ),
      ]);

      return right(null);
    } on CustomException catch (e, s) {
      log(e.toString(), stackTrace: s);
      await _rollbackUserCourse(course, userEntity);
      return left(ServerFailure(message: e.message));
    } catch (e) {
      log(e.toString());
      await _rollbackUserCourse(course, userEntity);
      return left(
        ServerFailure(
          message: "حدث خطأ أثناء إتمام عملية الاشتراك، يرجى المحاولة مرة أخرى",
        ),
      );
    }
  }

  Future<void> _updateCourseSubscriberCount({
    required String courseId,
    int delta = 1,
  }) async {
    await databaseService.updateData(
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.coursesCollection,
        docId: courseId,
      ),
      field: "studentsCount",
      data: FieldValue.increment(delta),
    );
  }

  Future<void> _addSubscriber(
    SubscriberEntity subscriber,
    FireStoreRequirmentsEntity requirements,
  ) async {
    final data = Subscripersidsmodel.fromEntit(
      subscriberentity: subscriber,
    ).toJson();
    await databaseService.setData(data: data, requirements: requirements);
  }

  SubscriberEntity _buildSubscriberEntity(UserEntity user) {
    return SubscriberEntity(
      id: user.uid,
      name: user.firstName,
      gender: user.gender.isEmpty ? "" : user.gender,
      phone: user.phoneNumber,
      educationLevel: user.studentExtraDataEntity?.educationLevel ?? "",
      imageUrl: user.profilePicurl,
      address: user.address,
    );
  }

  Future<void> _updateTeacherWalletBatch({
    required String teacherId,
    required double amount,
    required String transactionId,
  }) async {
    if (teacherId.isEmpty) return;

    final double netAmount = amount - (amount * 0.05);
    final updates = {
      "teacherExtraData.wallet.balance": FieldValue.increment(netAmount),
      "teacherExtraData.wallet.last_transaction_id": transactionId,
      "teacherExtraData.wallet.updated_at": DateTime.now().toIso8601String(),
      "teacherExtraData.wallet.total_earned": FieldValue.increment(netAmount),
    };

    for (final entry in updates.entries) {
      await databaseService.updateData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: teacherId,
        ),
        field: entry.key,
        data: entry.value,
      );
    }
  }

  FireStoreRequirmentsEntity _buildSubscriberReq(
    String courseId,
    String userId,
  ) {
    return FireStoreRequirmentsEntity(
      collection: BackendEndpoints.coursesCollection,
      docId: courseId,
      subDocId: userId,
      subCollection: BackendEndpoints.subscribersSubCollection,
    );
  }

  Future<void> _addCourseToUserList(
    CourseEntity course,
    UserEntity user,
  ) async {
    final data = Coursemodel.fromEntity(courseEntity: course).toJson();
    await databaseService.setData(
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.usersCollectionName,
        docId: user.uid,
        subDocId: course.id,
        subCollection: BackendEndpoints.subscribetoCourseCollection,
      ),
      data: data,
    );
  }

  Future<bool> _isCourseInUserList(CourseEntity course, UserEntity user) async {
    return await databaseService.isDataExists(
      key: BackendEndpoints.usersCollectionName,
      docId: user.uid,
      subDocId: course.id,
      subCollectionKey: BackendEndpoints.subscribetoCourseCollection,
    );
  }

  Future<void> _rollbackUserCourse(CourseEntity course, UserEntity user) async {
    if (await _isCourseInUserList(course, user)) {
      await databaseService.deleteDoc(
        collectionKey: BackendEndpoints.usersCollectionName,
        docId: user.uid,
        subDocId: course.id,
        subCollectionKey: BackendEndpoints.subscribetoCourseCollection,
      );
    }
  }

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
      return left(ServerFailure(message: "فشل التحقق من حالة الاشتراك"));
    }
  }

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
        return left(
          ServerFailure(message: "لم يتم العثور على أي مشتركين حالياً"),
        );
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
        ServerFailure(message: "حدث خطأ أثناء تحميل قائمة المشتركين"),
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
      return left(ServerFailure(message: "فشل الحصول على عدد المشتركين"));
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
        return left(ServerFailure(message: "لا توجد نتائج مطابقة للبحث"));
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
        ServerFailure(message: "حدث خطأ أثناء محاولة البحث عن مشترك"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> storeSubscribtionTransaction({
    required String courseID,
    required String userID,
    required TransactionEntity transaction,
  }) async {
    try {
      Map<String, dynamic> json = TransactionModel.fromEntity(
        transaction,
      ).toJson();
      await Future.wait([
        databaseService.setData(
          data: json,
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.coursesCollection,
            docId: courseID,
            subCollection: BackendEndpoints.transactionsSubCollection,
            subDocId: transaction.transactionId,
          ),
        ),
        databaseService.setData(
          data: json,
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.usersCollectionName,
            docId: userID,
            subCollection: BackendEndpoints.transactionsSubCollection,
            subDocId: transaction.transactionId,
          ),
        ),
        databaseService.setData(
          data: json,
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.transactionsCollection,
            docId: transaction.transactionId,
          ),
        ),
      ]);

      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "فشل في تسجيل بيانات المعاملة المالية"),
      );
    }
  }
}

List<SubscriberEntity> _parseSubscribers(List<dynamic> rawList) {
  return rawList
      .map((e) => Subscripersidsmodel.fromJson(e).toEntity())
      .toList();
}
