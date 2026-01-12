import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';
import 'package:sintir_dashboard/Features/Support/Data/Services/SupportAnalyticsService.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportAnalyticsRepo.dart';

class SupportAnalyticsRepoImpl implements SupportAnalyticsRepo {
  final SupportAnalyticsService supportAnalyticsService;

  SupportAnalyticsRepoImpl({required this.supportAnalyticsService});

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getTotalTickets() async {
    try {
      final result = await supportAnalyticsService.getTicketStats();
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getPendingTickets() async {
    try {
      final result = await supportAnalyticsService.getTicketStats(
        status: 'PENDING',
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getResolvedTickets() async {
    try {
      final result = await supportAnalyticsService.getTicketStats(
        status: 'RESOLVED',
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
