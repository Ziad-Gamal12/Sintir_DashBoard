import 'package:sintir_dashboard/Features/Auth/Domain/Entities/StudentExtraDataEntity.dart';

class StudentExtraDataModel {
  final String educationLevel;
  final String birthDate;

  StudentExtraDataModel({
    required this.educationLevel,
    required this.birthDate,
  });
  factory StudentExtraDataModel.fromJson(Map<String, dynamic> json) =>
      StudentExtraDataModel(
        educationLevel: json['educationLevel'],
        birthDate: json['birthDate'],
      );
  factory StudentExtraDataModel.fromEntity(StudentExtraDataEntity entity) =>
      StudentExtraDataModel(
        educationLevel: entity.educationLevel,
        birthDate: entity.birthDate,
      );
  StudentExtraDataEntity toEntity() => StudentExtraDataEntity(
    educationLevel: educationLevel,
    birthDate: birthDate,
  );
  Map<String, dynamic> toMap() {
    return {'educationLevel': educationLevel, 'birthDate': birthDate};
  }
}
