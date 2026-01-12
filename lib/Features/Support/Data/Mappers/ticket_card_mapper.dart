import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsCardViewModel.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/TicketsSummaryCardType.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_state.dart';

AnalyticsCardViewModel mapTicketStateToVM(
  TicketAnalyticsState state,
  TicketsSummaryCardType type,
) {
  switch (type) {
    case TicketsSummaryCardType.total:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingTotal,
        result: state.totalTickets,
      );
    case TicketsSummaryCardType.pending:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingPending,
        result: state.pendingTickets,
      );
    case TicketsSummaryCardType.resolved:
      return AnalyticsCardViewModel(
        isLoading: state.isLoadingResolved,
        result: state.resolvedTickets,
      );
  }
}
