import 'package:sintir_dashboard/Features/Auth/Domain/Entities/StudentExtraDataEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherExtraDataEntity.dart';

class UserEntity {
  String uid;
  String firstName;
  String lastName;
  String fullName;
  String email;
  String address;
  String phoneNumber;
  String deviceId;
  TeacherExtraDataEntity? teacherExtraDataEntity;
  StudentExtraDataEntity? studentExtraDataEntity;
  String gender;
  final String profilePicurl;
  String status;
  String role;
  final DateTime joinedDate;

  UserEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.deviceId,
    required this.gender,
    required this.profilePicurl,
    required this.status,
    required this.role,
    required this.joinedDate,
    required this.fullName,
    this.studentExtraDataEntity,
    this.teacherExtraDataEntity,
  });
  static UserEntity empty() => UserEntity(
    uid: "",
    firstName: "",
    lastName: "",
    email: "",
    address: "",
    phoneNumber: "",
    deviceId: "",
    gender: "",
    profilePicurl: "",
    status: "",
    role: "",
    joinedDate: DateTime.now(),
    fullName: "",
  );
  static List<UserEntity> fakeUsers() =>
      List.generate(10, (index) => UserEntity.empty());
}
