import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';

class GetSupportTicketsResponseEntity {
  final List<SupportTicketEntity> supportTickets;
  final bool hasMore, isPaginate;
  GetSupportTicketsResponseEntity({
    required this.supportTickets,
    required this.hasMore,
    required this.isPaginate,
  });
}
