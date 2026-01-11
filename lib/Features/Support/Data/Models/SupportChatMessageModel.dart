import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Features/Support/Data/Models/SupportSenderModel.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';

class SupportChatMessageModel {
  final String message;
  final Map<String, dynamic> sender;
  final String? image;
  final DateTime createdAt;
  final String id;

  SupportChatMessageModel({
    required this.message,
    required this.sender,
    required this.id,
    required this.image,
    required this.createdAt,
  });
  factory SupportChatMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportChatMessageModel(
      message: json['message'],
      sender: json['sender'],
      id: json['id'],
      image: json['image'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
  factory SupportChatMessageModel.fromEntity(SupportChatMessageEntity entity) {
    return SupportChatMessageModel(
      message: entity.message,
      sender: SupportSenderModel.fromEntity(entity.sender).toJson(),
      image: entity.image,
      id: entity.id,
      createdAt: entity.createdAt,
    );
  }
  SupportChatMessageEntity toEntity() {
    return SupportChatMessageEntity(
      message: message,
      sender: SupportSenderModel.fromJson(sender).toEntity(),
      image: image,
      id: id,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender': sender,
      'image': image,
      'id': id,
      'createdAt': createdAt,
    };
  }
}
