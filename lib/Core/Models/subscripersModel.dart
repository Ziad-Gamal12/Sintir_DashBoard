// ignore_for_file: file_names

import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';

class Subscripersidsmodel {
  final String id;
  final String name, gender, phone, educationLevel, imageUrl, address;

  Subscripersidsmodel({
    required this.id,
    required this.name,
    required this.gender,
    required this.phone,
    required this.educationLevel,
    required this.imageUrl,
    required this.address,
  });
  factory Subscripersidsmodel.fromEntit({
    required SubscriberEntity subscriberentity,
  }) {
    return Subscripersidsmodel(
      id: subscriberentity.id,
      name: subscriberentity.name,
      gender: subscriberentity.gender,
      phone: subscriberentity.phone,
      educationLevel: subscriberentity.educationLevel,
      imageUrl: subscriberentity.imageUrl,
      address: subscriberentity.address,
    );
  }

  factory Subscripersidsmodel.fromJson(Map<String, dynamic> json) {
    return Subscripersidsmodel(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
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
    'address': address,
  };
}
