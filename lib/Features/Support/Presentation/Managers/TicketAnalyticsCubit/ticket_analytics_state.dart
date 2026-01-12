import 'package:equatable/equatable.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class TicketAnalyticsState extends Equatable {
  final AnalyticsResultEntity? totalTickets;
  final AnalyticsResultEntity? pendingTickets;
  final AnalyticsResultEntity? resolvedTickets;

  final bool isLoadingTotal;
  final bool isLoadingPending;
  final bool isLoadingResolved;
  final String? errorMessage;

  const TicketAnalyticsState({
    this.totalTickets,
    this.pendingTickets,
    this.resolvedTickets,
    this.isLoadingTotal = false,
    this.isLoadingPending = false,
    this.isLoadingResolved = false,
    this.errorMessage,
  });

  TicketAnalyticsState copyWith({
    AnalyticsResultEntity? totalTickets,
    AnalyticsResultEntity? pendingTickets,
    AnalyticsResultEntity? resolvedTickets,
    bool? isLoadingTotal,
    bool? isLoadingPending,
    bool? isLoadingResolved,
    String? errorMessage,
  }) {
    return TicketAnalyticsState(
      totalTickets: totalTickets ?? this.totalTickets,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      resolvedTickets: resolvedTickets ?? this.resolvedTickets,
      isLoadingTotal: isLoadingTotal ?? this.isLoadingTotal,
      isLoadingPending: isLoadingPending ?? this.isLoadingPending,
      isLoadingResolved: isLoadingResolved ?? this.isLoadingResolved,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    totalTickets,
    pendingTickets,
    resolvedTickets,
    isLoadingTotal,
    isLoadingPending,
    isLoadingResolved,
    errorMessage,
  ];
}
