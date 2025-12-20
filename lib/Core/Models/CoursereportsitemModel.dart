import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';

class CoursereportsitemModel {
  final DateTime date;
  final String type;
  final String description;

  CoursereportsitemModel({
    required this.date,
    required this.type,
    required this.description,
  });
  factory CoursereportsitemModel.fromJson(Map<String, dynamic> json) {
    return CoursereportsitemModel(
      date: (json['date'] as Timestamp).toDate(),
      type: json['type'],
      description: json['description'],
    );
  }
  factory CoursereportsitemModel.fromEntity({
    required CourseReportEntity courseReportsItemEntity,
  }) {
    return CoursereportsitemModel(
      date: courseReportsItemEntity.date,
      type: courseReportsItemEntity.type,
      description: courseReportsItemEntity.description,
    );
  }
  CourseReportEntity toEntity() {
    return CourseReportEntity(date: date, type: type, description: description);
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'type': type, 'description': description};
  }
}
