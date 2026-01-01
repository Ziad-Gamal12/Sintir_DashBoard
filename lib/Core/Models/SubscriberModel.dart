// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';

class SubscriberModel {
  final String id;
  final String name, gender, phone, educationLevel, imageUrl, address;
  final DateTime? joinedDate;

  SubscriberModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.phone,
    required this.educationLevel,
    required this.joinedDate,
    required this.imageUrl,
    required this.address,
  });
  factory SubscriberModel.fromEntit({
    required SubscriberEntity subscriberentity,
  }) {
    return SubscriberModel(
      id: subscriberentity.id,
      name: subscriberentity.name,
      joinedDate: subscriberentity.joinedDate,
      gender: subscriberentity.gender,
      phone: subscriberentity.phone,
      educationLevel: subscriberentity.educationLevel,
      imageUrl: subscriberentity.imageUrl,
      address: subscriberentity.address,
    );
  }

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    return SubscriberModel(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      joinedDate: (json['joinedDate'] != null)
          ? (json['joinedDate'] as Timestamp).toDate()
          : null,
      phone: json['phone'],
      educationLevel: json['educationLevel'],
      imageUrl: json['imageUrl'],
      address: json['address'],
    );
  }
  SubscriberEntity toEntity() => SubscriberEntity(
    id: id,
    name: name,
    gender: gender,
    phone: phone,
    educationLevel: educationLevel,
    joinedDate: joinedDate,
    imageUrl: imageUrl,
    address: address,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'gender': gender,
    'phone': phone,
    'educationLevel': educationLevel,
    'imageUrl': imageUrl,
    'joinedDate': joinedDate,
    'address': address,
  };
}
