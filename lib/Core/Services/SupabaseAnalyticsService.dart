import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsResultModel.dart';
import 'package:sintir_dashboard/Core/Services/DioService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class SupabaseAnalyticsService {
  final DioService _dioService;
  SupabaseAnalyticsService(this._dioService);

  Future<AnalyticsResultEntity> _getStats({
    required String collection,
    String? status,
    String? sumField,
  }) async {
    final response = await _dioService.post(
      'sintir-analytics',
      data: {
        'targetCollection': collection,
        'statusFilter': status,
        'sumField': sumField,
      },
    );
    return AnalyticsResultModel.fromJson(response.data).toEntity();
  }

  Future<AnalyticsResultEntity> getRevenueStats() => _getStats(
    collection: BackendEndpoints.transactionsCollection,
    sumField: "amount",
  );
  Future<AnalyticsResultEntity> getUserGrowth() => _getStats(
    collection: BackendEndpoints.usersCollectionName,
    status: BackendEndpoints.activeStatus,
  );
  Future<AnalyticsResultEntity> getLiveCourseStats() => _getStats(
    collection: BackendEndpoints.coursesCollection,
    status: BackendEndpoints.coursePublishedState,
  );
  Future<AnalyticsResultEntity> getTicketStats() =>
      _getStats(collection: BackendEndpoints.supportTicketsCollection);
}
