import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/StudentExtraDataEntity.dart';

class StudentExtraDataModel {
  final String? educationLevel;
  final DateTime? birthDate;

  StudentExtraDataModel(
      {required this.educationLevel, required this.birthDate});
  factory StudentExtraDataModel.fromJson(Map<String, dynamic> json) =>
      StudentExtraDataModel(
          educationLevel: json['educationLevel'],
          birthDate: date(json['birthDate']));
  factory StudentExtraDataModel.fromEntity(StudentExtraDataEntity entity) =>
      StudentExtraDataModel(
          educationLevel: entity.educationLevel, birthDate: entity.birthDate);
  StudentExtraDataEntity toEntity() => StudentExtraDataEntity(
      educationLevel: educationLevel ?? "", birthDate: birthDate);
  Map<String, dynamic> toMap() {
    return {
      'educationLevel': educationLevel,
      'birthDate': birthDate,
    };
  }

  static DateTime? date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
