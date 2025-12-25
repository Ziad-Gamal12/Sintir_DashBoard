import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class AnalyticsResultModel {
  final bool isIncreasing;
  final String percentage;
  final double currentTotal;

  AnalyticsResultModel({
    required this.isIncreasing,
    required this.percentage,
    required this.currentTotal,
  });

  factory AnalyticsResultModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsResultModel(
      isIncreasing: json['isIncreasing'] ?? false,
      percentage: json['percentage'] ?? "0.0",
      currentTotal: (json['currentTotal'] as num).toDouble(),
    );
  }

  AnalyticsResultEntity toEntity() => AnalyticsResultEntity(
    isIncreasing: isIncreasing,
    percentage: percentage,
    currentTotal: currentTotal,
  );
}
