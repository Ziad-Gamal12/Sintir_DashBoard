import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsCardViewModel.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/DashboardSummaryCardType.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_state.dart';

AnalyticsCardViewModel mapStateToAnalyticsCardVM(
  DashbaordAnalyticsState state,
  DashboardSummaryCardType type,
) {
  switch (type) {
    case DashboardSummaryCardType.revenue:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingRevenue,
        result: state.revenue,
      );
    case DashboardSummaryCardType.users:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingUsers,
        result: state.users,
      );
    case DashboardSummaryCardType.courses:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingCourses,
        result: state.courses,
      );
    case DashboardSummaryCardType.tickets:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingTickets,
        result: state.tickets,
      );
  }
}
