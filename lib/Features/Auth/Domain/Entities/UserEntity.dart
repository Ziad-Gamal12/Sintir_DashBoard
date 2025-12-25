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
  final String status;
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
    uid: "empty",
    firstName: "empty",
    lastName: "empty",
    email: "empty",
    address: "empty",
    phoneNumber: "empty",
    deviceId: "empty",
    gender: "empty",
    profilePicurl: "https://cdn-icons-png.flaticon.com/128/15239/15239514.png",
    status: "empty",
    role: "empty",
    joinedDate: DateTime.now(),
    fullName: "empty",
  );
}
