import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsResultModel.dart';
import 'package:sintir_dashboard/Core/Services/DioService.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class SupportAnalyticsService {
  final DioService _dioService;
  SupportAnalyticsService(this._dioService);

  Future<AnalyticsResultEntity> getTicketStats({String? status}) async {
    final response = await _dioService.post(
      'ticket-analytics',
      data: {'statusFilter': status},
    );
    return AnalyticsResultModel.fromJson(response.data).toEntity();
  }
}
