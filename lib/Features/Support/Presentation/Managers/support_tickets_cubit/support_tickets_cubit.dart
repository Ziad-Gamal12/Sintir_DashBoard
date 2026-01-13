import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/FilterTicketsQueryEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/GetSupportTicketsResponseEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';

part 'support_tickets_state.dart';

class SupportTicketsCubit extends Cubit<SupportTicketsState> {
  SupportTicketsCubit({required this.supportTicketsRepo})
    : super(SupportTicketsInitial());
  final SupportTicketsRepo supportTicketsRepo;
  // Send Support Ticket
  Future<void> sendSupportTicket({
    required SupportTicketEntity supportTicket,
  }) async {
    emit(SendSupportTicketLoading());
    final response = await supportTicketsRepo.sendSupportTicket(
      supportTicket: supportTicket,
    );
    response.fold(
      (failure) => emit(SendSupportTicketFailure(errMessage: failure.message)),
      (response) => emit(SendSupportTicketSuccess()),
    );
  }

  // Delete Support Ticket
  Future<void> deleteSupportTicket({required String ticketId}) async {
    emit(DeleteSupportTicketLoading());
    final response = await supportTicketsRepo.deleteSupportTicket(
      ticketId: ticketId,
    );
    response.fold(
      (failure) =>
          emit(DeleteSupportTicketFailure(errMessage: failure.message)),
      (response) => emit(DeleteSupportTicketSuccess()),
    );
  }

  // Change Support Ticket Status
  Future<void> changeSupportTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    emit(UpdateSupportTicketStatusLoading());
    final response = await supportTicketsRepo.updateSupportTicketStatus(
      supportTicketId: ticketId,
      status: status,
    );
    response.fold(
      (failure) =>
          emit(UpdateSupportTicketStatusFailure(errMessage: failure.message)),
      (response) => emit(UpdateSupportTicketStatusSuccess()),
    );
  }

  // get  Support Tickets
  Future<void> getSupportTickets(
    FilterTicketsQueryEntity? filterTicketsQueryEntity, {
    required bool isPaginate,
  }) async {
    emit(GetSupportTicketsLoading(isPaginate: isPaginate));
    final response = await supportTicketsRepo.getSupportTickets(
      filterTicketsQueryEntity,
      isPaginate: isPaginate,
    );
    response.fold(
      (failure) => emit(GetSupportTicketsFailure(errMessage: failure.message)),
      (response) => emit(GetSupportTicketsSuccess(response: response)),
    );
  }
}
