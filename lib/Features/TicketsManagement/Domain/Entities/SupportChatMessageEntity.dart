import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportSenderEntity.dart';

class SupportChatMessageEntity {
  String message;
  final SupportSenderEntity sender;
  String? image;
  final DateTime createdAt;
  final String id;

  SupportChatMessageEntity({
    required this.sender,
    required this.createdAt,
    required this.message,
    required this.id,
    this.image,
  });
}
