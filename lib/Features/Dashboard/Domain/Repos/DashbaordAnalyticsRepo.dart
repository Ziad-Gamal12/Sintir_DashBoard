import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';

abstract class DashbaordAnalyticsRepo {
  Future<Either<Failure, AnalyticsResultEntity>> getRevenueStats();

  Future<Either<Failure, AnalyticsResultEntity>> getUserGrowth();

  Future<Either<Failure, AnalyticsResultEntity>> getLiveCourseStats();

  Future<Either<Failure, AnalyticsResultEntity>> getTicketStats();

  Future<Either<Failure, List<TransactionEntity>>> getGraphTransactions();

  Future<Either<Failure, GenderAnalysisEntity>> analyzeUsersGender();
}
