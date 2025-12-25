import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

abstract class DashbaordAnalyticsRepo {
  Future<Either<Failure, AnalyticsResultEntity>> getRevenueStats();

  Future<Either<Failure, AnalyticsResultEntity>> getUserGrowth();

  Future<Either<Failure, AnalyticsResultEntity>> getLiveCourseStats();

  Future<Either<Failure, AnalyticsResultEntity>> getTicketStats();
}
