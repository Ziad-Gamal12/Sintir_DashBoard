import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_state.dart';

class TicketAnalyticsCubit extends Cubit<TicketAnalyticsState> {
  final SupportAnalyticsRepo supportRepo;

  TicketAnalyticsCubit({required this.supportRepo})
    : super(const TicketAnalyticsState());

  Future<void> fetchAllStats() async {
    await Future.wait([
      getTotalTickets(),
      getPendingTickets(),
      getResolvedTickets(),
    ]);
  }

  Future<void> getTotalTickets() async {
    emit(state.copyWith(isLoadingTotal: true));
    final result = await supportRepo.getTotalTickets();
    result.fold(
      (l) =>
          emit(state.copyWith(isLoadingTotal: false, errorMessage: l.message)),
      (r) => emit(state.copyWith(totalTickets: r, isLoadingTotal: false)),
    );
  }

  Future<void> getPendingTickets() async {
    emit(state.copyWith(isLoadingPending: true));
    final result = await supportRepo.getPendingTickets();
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingPending: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(pendingTickets: r, isLoadingPending: false)),
    );
  }

  Future<void> getResolvedTickets() async {
    emit(state.copyWith(isLoadingResolved: true));
    final result = await supportRepo.getResolvedTickets();
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingResolved: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(resolvedTickets: r, isLoadingResolved: false)),
    );
  }
}
