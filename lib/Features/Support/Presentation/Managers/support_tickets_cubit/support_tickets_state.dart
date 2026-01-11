part of 'support_tickets_cubit.dart';

@immutable
sealed class SupportTicketsState {}

final class SupportTicketsInitial extends SupportTicketsState {}

// send Ticket
final class SendSupportTicketLoading extends SupportTicketsState {}

final class SendSupportTicketSuccess extends SupportTicketsState {}

final class SendSupportTicketFailure extends SupportTicketsState {
  final String errMessage;
  SendSupportTicketFailure({required this.errMessage});
}

// Delete Ticket
final class DeleteSupportTicketLoading extends SupportTicketsState {}

final class DeleteSupportTicketSuccess extends SupportTicketsState {}

final class DeleteSupportTicketFailure extends SupportTicketsState {
  final String errMessage;
  DeleteSupportTicketFailure({required this.errMessage});
}

// Get User Support Tickets
final class GetSupportTicketsLoading extends SupportTicketsState {
  final bool isPaginate;
  GetSupportTicketsLoading({required this.isPaginate});
}

final class GetSupportTicketsSuccess extends SupportTicketsState {
  final GetSupportTicketsResponseEntity response;
  GetSupportTicketsSuccess({required this.response});
}

final class GetSupportTicketsFailure extends SupportTicketsState {
  final String errMessage;
  GetSupportTicketsFailure({required this.errMessage});
}
