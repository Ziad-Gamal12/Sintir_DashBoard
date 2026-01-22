import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Models/CourseModel.dart';
import 'package:sintir_dashboard/Core/Models/Transactions/TransactionModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/UserModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserDetailRepo.dart';

class UserDetailsRepoImpl implements UserDetailsRepo {
  final DataBaseService dataBaseService;
  final FirebaseAuthService firebaseAuthService;

  UserDetailsRepoImpl({
    required this.dataBaseService,
    required this.firebaseAuthService,
  });
  @override
  Future<Either<Failure, void>> deleteUser({required String uid}) async {
    try {
      Future.wait([
        dataBaseService.deleteDoc(
          collectionKey: BackendEndpoints.usersCollectionName,
          docId: uid,
        ),
        // solve this problem to delete user from firebase auth by uid
        //firebaseAuthService.deleteUSer(),
      ]);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUser({required String userID}) async {
    try {
      final resulte = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: userID,
        ),
      );
      log(resulte.docData.toString());
      final user = UserModel.fromJson(resulte.docData!).toEntity();
      return right(user);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getUserCourses({
    required String uid,
  }) async {
    try {
      final resulte = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          subCollection: BackendEndpoints.getCoursesfromUserDocSubCollectioName,
          docId: uid,
        ),
      );
      if (resulte.listData == null || resulte.listData!.isEmpty) {
        return right([]);
      }
      final courses = await compute(
        _parceUserCourses,
        resulte.listData as List<Map<String, dynamic>>,
      );
      return right(courses);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions({
    required String uid,
  }) async {
    try {
      final resulte = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          subCollection: BackendEndpoints.transactionsSubCollection,
          docId: uid,
        ),
      );
      if (resulte.listData == null || resulte.listData!.isEmpty) {
        return right([]);
      }
      final transactions = await compute(
        _parseUserTransactions,
        resulte.listData as List<Map<String, dynamic>>,
      );
      return right(transactions);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUser({
    required UserEntity userEntity,
  }) async {
    try {
      await dataBaseService.setData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: userEntity.uid,
        ),
        data: UserModel.fromEntity(userEntity).toMap(),
      );
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUserSupportTicketsCount({
    required String uid,
  }) async {
    try {
      final resulte = await dataBaseService.getCollectionItemsCount(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
        ),
        query: {
          "filters": [
            {"field": "sender.uid", "operator": "==", "value": uid},
          ],
        },
      );

      return right(resulte);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }
}

List<CourseEntity> _parceUserCourses(List<Map<String, dynamic>> data) {
  List<CourseEntity> courses = data
      .map((e) => CourseModel.fromJson(e).toEntity())
      .toList();
  return courses;
}

List<TransactionEntity> _parseUserTransactions(
  List<Map<String, dynamic>> data,
) {
  List<TransactionEntity> transactions = data
      .map((e) => TransactionModel.fromJson(e).toEntity())
      .toList();
  return transactions;
}
