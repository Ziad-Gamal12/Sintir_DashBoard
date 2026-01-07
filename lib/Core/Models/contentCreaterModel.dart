// ignore_for_file: file_names

import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class Contentcreatermodel {
  final String name, profileImageUrl, id, title;

  Contentcreatermodel({
    required this.name,
    required this.profileImageUrl,
    required this.id,
    required this.title,
  });

  factory Contentcreatermodel.fromTeacherEntity({
    required UserEntity userEntity,
  }) {
    return Contentcreatermodel(
      name: "${userEntity.firstName} ${userEntity.lastName}",
      profileImageUrl: userEntity.profilePicurl,
      id: userEntity.uid,
      title:
          "${"معلم ماده "}${userEntity.teacherExtraDataEntity?.subject ?? ""}",
    );
  }
  factory Contentcreatermodel.fromEntity({
    required ContentCreatorEntity entity,
  }) {
    return Contentcreatermodel(
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
      id: entity.id,
      title: entity.title,
    );
  }
  factory Contentcreatermodel.fromJson({required Map data}) {
    return Contentcreatermodel(
      name: data["name"] ?? "unknown",
      profileImageUrl: data["profileImageUrl"],
      id: data["id"],
      title: data["title"],
    );
  }
  factory Contentcreatermodel.fromTeacherJson({required Map data}) {
    return Contentcreatermodel(
      name: data["fullName"] ?? "unknown",
      profileImageUrl: data["profilePicurl"],
      id: data["uid"],
      title: data["teacherExtraData"]["subject"],
    );
  }
  ContentCreatorEntity toEntity() {
    return ContentCreatorEntity(
      name: name,
      profileImageUrl: profileImageUrl,
      id: id,
      title: title,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profileImageUrl": profileImageUrl,
      "id": id,
      "title": title,
    };
  }
}
