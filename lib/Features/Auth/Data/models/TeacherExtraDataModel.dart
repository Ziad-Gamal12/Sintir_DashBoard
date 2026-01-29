import 'package:sintir_dashboard/Features/Auth/Data/models/TeacherWalletModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherExtraDataEntity.dart';

class TeacherExtraDataModel {
  final String subject;
  final String workExperience;
  final Map<String, dynamic> wallet;
  TeacherExtraDataModel({
    required this.wallet,
    required this.subject,
    required this.workExperience,
  });

  factory TeacherExtraDataModel.fromJson(Map<String, dynamic> json) {
    return TeacherExtraDataModel(
      subject: json['subject'] ?? "",
      workExperience: json['workExperience'] ?? "",
      wallet: json['wallet'],
    );
  }
  factory TeacherExtraDataModel.fromEntity(TeacherExtraDataEntity entity) {
    return TeacherExtraDataModel(
      subject: entity.subject,
      workExperience: entity.workExperience,
      wallet: TeacherWalletModel.fromEntity(entity.wallet).toJson(),
    );
  }
  TeacherExtraDataEntity toEntity() {
    return TeacherExtraDataEntity(
      wallet: TeacherWalletModel.fromJson(wallet).toEntity(),
      subject: subject,
      workExperience: workExperience,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'wallet': wallet,
      'workExperience': workExperience,
    };
  }
}
