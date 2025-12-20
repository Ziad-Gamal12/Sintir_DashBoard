// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Models/contentCreaterModel.dart';

class Coursemodel {
  final String id, posterUrl, title, description, language, state;
  final int price;
  final int studentsCount;
  final String subject;
  final String level;
  final DateTime postedDate;
  final Map contentcreaterentity;

  Coursemodel({
    required this.id,
    required this.posterUrl,
    required this.studentsCount,
    required this.title,
    required this.description,
    required this.price,
    required this.language,
    required this.subject,
    required this.level,
    required this.state,
    required this.postedDate,
    required this.contentcreaterentity,
  });

  factory Coursemodel.fromEntity({required CourseEntity courseEntity}) {
    return Coursemodel(
      id: courseEntity.id,
      posterUrl: courseEntity.posterUrl ?? "",
      subject: courseEntity.subject,
      level: courseEntity.level,
      title: courseEntity.title,
      description: courseEntity.description,
      price: courseEntity.price,
      language: courseEntity.language,
      studentsCount: courseEntity.studentsCount,
      state: courseEntity.state,
      postedDate: courseEntity.postedDate,
      contentcreaterentity: courseEntity.contentcreaterentity != null
          ? Contentcreatermodel.fromEntity(
              entity: courseEntity.contentcreaterentity!,
            ).toJson()
          : {},
    );
  }
  factory Coursemodel.fromJson(Map<String, dynamic> json) {
    return Coursemodel(
      id: json['id'],
      posterUrl: json['posterUrl'],
      title: json['title'],
      description: json['description'],
      studentsCount: (json['studentsCount'] as num).toInt(),
      price: json['price'],
      subject: json['subject'],
      level: json['level'],
      language: json['language'],
      state: json['state'],
      postedDate: (json['postedDate'] as Timestamp).toDate(),
      contentcreaterentity: json['contentcreaterentity'],
    );
  }
  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      posterUrl: posterUrl,
      title: title,
      description: description,
      studentsCount: studentsCount,
      price: price,
      language: language,
      subject: subject,
      level: level,
      state: state,
      postedDate: postedDate,
      contentcreaterentity: Contentcreatermodel.fromJson(
        data: contentcreaterentity,
      ).toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posterUrl': posterUrl,
      'title': title,
      'description': description,
      'studentsCount': studentsCount,
      'contentcreaterentity': contentcreaterentity,
      'price': price,
      'language': language,
      'subject': subject,
      'level': level,
      'state': state,
      'postedDate': postedDate,
    };
  }
}
