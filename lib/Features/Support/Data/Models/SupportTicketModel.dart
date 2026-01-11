import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Features/Support/Data/Models/SupportSenderModel.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';

class SupportTicketModel {
  final Map<String, dynamic> sender;
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  SupportTicketModel({
    required this.sender,
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      sender: json['sender'],
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      status: json['status'],
    );
  }
  factory SupportTicketModel.fromEntity(SupportTicketEntity entity) {
    return SupportTicketModel(
      sender: SupportSenderModel.fromEntity(entity.sender).toJson(),
      id: entity.id,
      title: entity.title,
      category: entity.category,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
    );
  }
  SupportTicketEntity toEntity() {
    return SupportTicketEntity(
      sender: SupportSenderModel.fromJson(sender).toEntity(),
      id: id,
      title: title,
      category: category,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }
}
