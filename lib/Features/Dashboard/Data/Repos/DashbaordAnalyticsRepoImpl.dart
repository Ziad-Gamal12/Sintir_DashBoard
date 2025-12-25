import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Services/SupabaseAnalyticsService.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';

class DashbaordAnalyticsRepoImpl implements DashbaordAnalyticsRepo {
  final SupabaseAnalyticsService supabaseAnalyticsService;

  DashbaordAnalyticsRepoImpl({required this.supabaseAnalyticsService});

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
}
