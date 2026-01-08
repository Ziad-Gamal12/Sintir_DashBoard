import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportSenderEntity.dart';

class SupportSenderModel {
  final String name;
  final String email;
  final String phone;
  final String uid;
  final String photoUrl;
  final String role;

  SupportSenderModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.uid,
    required this.photoUrl,
    required this.role,
  });

  factory SupportSenderModel.fromJson(Map<String, dynamic> json) {
    return SupportSenderModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      uid: json['uid'],
      photoUrl: json['photoUrl'],
      role: json['role'],
    );
  }
  factory SupportSenderModel.fromEntity(SupportSenderEntity entity) {
    return SupportSenderModel(
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      uid: entity.uid,
      photoUrl: entity.photoUrl,
      role: entity.role,
    );
  }
  SupportSenderEntity toEntity() {
    return SupportSenderEntity(
      name: name,
      email: email,
      phone: phone,
      uid: uid,
      photoUrl: photoUrl,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uid': uid,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
