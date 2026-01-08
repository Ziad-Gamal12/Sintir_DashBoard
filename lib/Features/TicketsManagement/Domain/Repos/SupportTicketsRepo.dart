import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/GetSupportTicketsResponseEntity.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportTicketEntity.dart';

abstract class SupportTicketsRepo {
  Future<Either<Failure, void>> sendSupportTicket({
    required SupportTicketEntity supportTicket,
  });
  Future<Either<Failure, void>> deleteSupportTicket({required String ticketId});
  Future<Either<Failure, void>> updateSupportTicketStatus({
    required String supportTicketId,
    required String status,
  });

  Future<Either<Failure, GetSupportTicketsResponseEntity>>
  getUserSupportTickets({required String userId, required bool isPaginate});
}
