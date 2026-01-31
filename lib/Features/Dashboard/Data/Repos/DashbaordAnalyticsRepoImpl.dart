import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Models/Transactions/TransactionModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/SupabaseAnalyticsService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';

class DashbaordAnalyticsRepoImpl implements DashbaordAnalyticsRepo {
  final SupabaseAnalyticsService supabaseAnalyticsService;
  final DataBaseService dataBaseService;
  DashbaordAnalyticsRepoImpl({
    required this.supabaseAnalyticsService,
    required this.dataBaseService,
  });

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getLiveCourseStats() async {
    try {
      return right(await supabaseAnalyticsService.getLiveCourseStats());
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getRevenueStats() async {
    try {
      return right(await supabaseAnalyticsService.getRevenueStats());
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getTicketStats() async {
    try {
      return right(await supabaseAnalyticsService.getTicketStats());
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getUserGrowth() async {
    try {
      return right(await supabaseAnalyticsService.getUserGrowth());
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GenderAnalysisEntity>> analyzeUsersGender() async {
    try {
      // 1. AWAIT the results and destructure them
      final results = await Future.wait([
        getUsersCount(),
        getMaleUsersCount(),
        getFemaleUsersCount(),
      ]);

      final int usersCount = results[0];
      final int maleUsersCount = results[1];
      final int femaleUsersCount = results[2];

      if (usersCount == 0) {
        return right(GenderAnalysisEntity.empty());
      }

      double malePercent = (maleUsersCount / usersCount) * 100;
      double femalePercent = (femaleUsersCount / usersCount) * 100;

      return right(
        GenderAnalysisEntity(
          femaleCount: femaleUsersCount,
          maleCount: maleUsersCount,
          femalePercentage: femalePercent,
          malePercentage: malePercent,
        ),
      );
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<int> getUsersCount() {
    return dataBaseService.getCollectionItemsCount(
      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.usersCollectionName,
      ),
    );
  }

  Future<int> getMaleUsersCount() async {
    Map<String, dynamic> query = {
      "filters": [
        {"field": "gender", "operator": "==", "value": "Male"},
      ],
    };

    return await dataBaseService.getCollectionItemsCount(
      query: query,

      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.usersCollectionName,
      ),
    );
  }

  Future<int> getFemaleUsersCount() async {
    Map<String, dynamic> query = {
      "filters": [
        {"field": "gender", "operator": "==", "value": "Female"},
      ],
    };

    return await dataBaseService.getCollectionItemsCount(
      query: query,

      requirements: FireStoreRequirmentsEntity(
        collection: BackendEndpoints.usersCollectionName,
      ),
    );
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>>
  getGraphTransactions() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      Map<String, dynamic> query = {
        "filters": [
          {"field": "created_at", "operator": "<=", "value": now},
          {"field": "created_at", "operator": ">=", "value": thirtyDaysAgo},
        ],
        "orderBy": "created_at",
        "limit": 30,
      };

      FireStoreResponse response = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.transactionsCollection,
        ),
        query: query,
      );

      final data = response.listData;
      if (data == null) {
        return left(ServerFailure(message: "فشل التحميل"));
      }

      if (data.isEmpty) return right([]);

      List<TransactionEntity> transactions = await compute(
        _parseTransactions,
        data.cast<Map<String, dynamic>>(),
      );

      return right(transactions);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطأ أثناء محاولة تحميل المعاملات"),
      );
    }
  }
}

List<TransactionEntity> _parseTransactions(List<Map<String, dynamic>> data) {
  return data.map((e) => TransactionModel.fromJson(e).toEntity()).toList();
}
