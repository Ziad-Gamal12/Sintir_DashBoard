import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsCardViewModel.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Entities/CourseDetailsSummaryCardType.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseAnalyticsCubit/CourseAnalyticsState.dart';

AnalyticsCardViewModel mapCourseStateToAnalyticsCardVM(
  CourseAnalyticsState state,
  CourseDetailsSummaryCardType type,
) {
  switch (type) {
    case CourseDetailsSummaryCardType.revenue:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingRevenue,
        result: state.revenue,
      );
    case CourseDetailsSummaryCardType.subscribers:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingSubscribers,
        result: state.subscribers,
      );
    case CourseDetailsSummaryCardType.feedbacks:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingFeedbacks,
        result: state.feedbacks,
      );
    case CourseDetailsSummaryCardType.reports:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingReports,
        result: state.reports,
      );
  }
}
