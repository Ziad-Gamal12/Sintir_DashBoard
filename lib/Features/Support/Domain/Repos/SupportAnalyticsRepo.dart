import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

abstract class SupportAnalyticsRepo {
  Future<Either<Failure, AnalyticsResultEntity>> getTotalTickets();
  Future<Either<Failure, AnalyticsResultEntity>> getPendingTickets();
  Future<Either<Failure, AnalyticsResultEntity>> getResolvedTickets();
}
