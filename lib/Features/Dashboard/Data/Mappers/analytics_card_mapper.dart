import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_state.dart';

import '../../Domain/Entities/SummaryCardType.dart';
import '../Models/AnalyticsCardViewModel.dart';

AnalyticsCardViewModel mapStateToAnalyticsCardVM(
  DashbaordAnalyticsState state,
  SummaryCardType type,
) {
  switch (type) {
    case SummaryCardType.revenue:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingRevenue,
        result: state.revenue,
      );
    case SummaryCardType.users:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingUsers,
        result: state.users,
      );
    case SummaryCardType.courses:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingCourses,
        result: state.courses,
      );
    case SummaryCardType.tickets:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingTickets,
        result: state.tickets,
      );
  }
}
