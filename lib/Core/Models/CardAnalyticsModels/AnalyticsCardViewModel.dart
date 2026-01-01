import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class AnalyticsCardViewModel {
  final bool isLoading;
  final AnalyticsResultEntity? result;

  const AnalyticsCardViewModel({required this.isLoading, required this.result});
}
