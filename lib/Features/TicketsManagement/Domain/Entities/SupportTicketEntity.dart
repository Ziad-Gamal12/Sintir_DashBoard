import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportSenderEntity.dart';

class SupportTicketEntity {
  SupportSenderEntity sender;
  final String id;
  String title;
  String category;
  String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  SupportTicketEntity({
    required this.sender,
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });
  static List<SupportTicketEntity> fakeSupportTickets() {
    return List.generate(
      6,
      (index) => SupportTicketEntity(
        sender: SupportSenderEntity.empty(),
        id: '12414123',
        title: 'حل مشكله اشتراك فى الكورس',
        category: 'Subscription',
        description: 'حل مشكله اشتراك فى الكورس',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'high_priority',
      ),
    );
  }
}

extension TicketStatusX on String {
  Color get toTicketColor {
    switch (toUpperCase()) {
      case 'OPEN':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'PENDING':
        return Colors.amber;
      case 'CLOSED':
        return Colors.red;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'URGENT':
        return Colors.red;
      case 'HIGH_PRIORITY':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get toArabicStatus {
    switch (toUpperCase()) {
      case 'OPEN':
        return "مفتوحة";
      case 'RESOLVED':
        return "تم الحل";
      case 'PENDING':
        return "قيد الانتظار";
      case 'CLOSED':
        return "مغلقة";
      case 'IN_PROGRESS':
        return "قيد التنفيذ";
      case 'URGENT':
        return "عاجل";
      case 'HIGH_PRIORITY':
        return "اولوية عالية";
      default:
        return "غير معروف";
    }
  }
}
