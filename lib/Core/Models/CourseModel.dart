// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Models/contentCreaterModel.dart';

class CourseModel {
  final String id, posterUrl, title, description, language, state;
  final int price;
  final int studentsCount;
  final String subject;
  final String level;
  final DateTime postedDate;
  final Map contentcreaterentity;
  final String? declineReason;
  final DateTime? declinedAt;
  final DateTime? resubmittedAt;

  CourseModel({
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
    this.declineReason,
    this.declinedAt,
    this.resubmittedAt,
  });

  static DateTime? dateOrNull(Object? value) =>
      value is Timestamp ? value.toDate() : (value is DateTime ? value : null);

  factory CourseModel.fromEntity({required CourseEntity courseEntity}) {
    return CourseModel(
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
      declineReason: courseEntity.declineReason,
      declinedAt: courseEntity.declinedAt,
      resubmittedAt: courseEntity.resubmittedAt,
    );
  }
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
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
      declineReason: json['declineReason'] is String
          ? json['declineReason'] as String
          : null,
      declinedAt: dateOrNull(json['declinedAt']),
      resubmittedAt: dateOrNull(json['resubmittedAt']),
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
      declineReason: declineReason,
      declinedAt: declinedAt,
      resubmittedAt: resubmittedAt,
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
