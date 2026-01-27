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
    uid: "132412",
    firstName: "زياد",
    lastName: "جمال",
    email: "ziadgamail.com",
    address: "محلة سبك اشمون",
    phoneNumber: "0123456789",
    deviceId: "44423525352",
    gender: "Male",
    profilePicurl: "https://cdn-icons-png.flaticon.com/128/15239/15239514.png",
    status: "Active",
    role: "Admin",
    joinedDate: DateTime.now(),
    fullName: "زياد جمال",
  );
  static List<UserEntity> fakeUsers() =>
      List.generate(10, (index) => UserEntity.empty());
}
