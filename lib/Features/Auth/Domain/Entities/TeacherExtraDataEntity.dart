import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';

class TeacherExtraDataEntity {
  String subject;
  String workExperience;
  TeacherWalletEntity wallet;
  TeacherExtraDataEntity({
    required this.wallet,
    required this.subject,
    required this.workExperience,
  });
}
