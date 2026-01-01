import 'package:equatable/equatable.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class CourseAnalyticsState extends Equatable {
  final AnalyticsResultEntity? revenue;
  final AnalyticsResultEntity? subscribers;
  final AnalyticsResultEntity? reports;
  final AnalyticsResultEntity? feedbacks;

  final bool isLoadingRevenue;
  final bool isLoadingSubscribers;
  final bool isLoadingReports;
  final bool isLoadingFeedbacks;

  final String? errorMessage;

  const CourseAnalyticsState({
    this.revenue,
    this.subscribers,
    this.reports,
    this.feedbacks,
    this.isLoadingRevenue = false,
    this.isLoadingSubscribers = false,
    this.isLoadingReports = false,
    this.isLoadingFeedbacks = false,
    this.errorMessage,
  });

  CourseAnalyticsState copyWith({
    AnalyticsResultEntity? revenue,
    AnalyticsResultEntity? subscribers,
    AnalyticsResultEntity? reports,
    AnalyticsResultEntity? feedbacks,
    bool? isLoadingRevenue,
    bool? isLoadingSubscribers,
    bool? isLoadingReports,
    bool? isLoadingFeedbacks,
    String? errorMessage,
  }) {
    return CourseAnalyticsState(
      revenue: revenue ?? this.revenue,
      subscribers: subscribers ?? this.subscribers,
      reports: reports ?? this.reports,
      feedbacks: feedbacks ?? this.feedbacks,
      isLoadingRevenue: isLoadingRevenue ?? this.isLoadingRevenue,
      isLoadingSubscribers: isLoadingSubscribers ?? this.isLoadingSubscribers,
      isLoadingReports: isLoadingReports ?? this.isLoadingReports,
      isLoadingFeedbacks: isLoadingFeedbacks ?? this.isLoadingFeedbacks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    revenue,
    subscribers,
    reports,
    feedbacks,
    isLoadingRevenue,
    isLoadingSubscribers,
    isLoadingReports,
    isLoadingFeedbacks,
    errorMessage,
  ];
}
