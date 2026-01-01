import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsResultModel.dart';
import 'package:sintir_dashboard/Core/Services/DioService.dart';
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

  Future<AnalyticsResultEntity> getRevenueStats() =>
      _getStats(collection: 'Transactions', sumField: "amount");
  Future<AnalyticsResultEntity> getUserGrowth() =>
      _getStats(collection: 'Users', status: "Active");
  Future<AnalyticsResultEntity> getLiveCourseStats() =>
      _getStats(collection: 'Courses', status: "published");
  Future<AnalyticsResultEntity> getTicketStats() =>
      _getStats(collection: 'SupportTickets');
}
