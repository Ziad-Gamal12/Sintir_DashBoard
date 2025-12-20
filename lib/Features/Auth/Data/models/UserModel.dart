import 'package:sintir_dashboard/Features/Auth/Data/models/StudentExtraDataModel.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/TeacherExtraDataModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String address;
  final String phoneNumber;
  final String? deviceId;
  Map<String, dynamic>? studentExtraData;
  Map<String, dynamic>? teacherExtraData;
  final String gender;
  final String profilePicurl;
  final String status;
  final String role;
  final String joinedDate;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.deviceId,
    required this.gender,
    required this.profilePicurl,
    required this.status,
    required this.role,
    required this.joinedDate,
    this.studentExtraData,
    this.teacherExtraData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      deviceId: json['deviceId'],
      phoneNumber: json['phoneNumber'],
      teacherExtraData: json['teacherExtraData'],
      studentExtraData: json['studentExtraData'],
      gender: json['gender'],
      profilePicurl: json['profilePicurl'],
      status: json['status'],
      role: json['role'],
      joinedDate: json['joinedDate'],
    );
  }
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      fullName: entity.fullName,
      deviceId: entity.deviceId,
      studentExtraData: entity.studentExtraDataEntity != null
          ? StudentExtraDataModel.fromEntity(
              entity.studentExtraDataEntity!,
            ).toMap()
          : null,
      teacherExtraData: entity.teacherExtraDataEntity != null
          ? TeacherExtraDataModel.fromEntity(
              entity.teacherExtraDataEntity!,
            ).toMap()
          : null,
      address: entity.address,
      phoneNumber: entity.phoneNumber,
      gender: entity.gender,
      profilePicurl: entity.profilePicurl,
      status: entity.status,
      role: entity.role,
      joinedDate: entity.joinedDate,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      firstName: firstName,
      fullName: fullName,
      deviceId: deviceId ?? "",
      lastName: lastName,
      email: email,
      studentExtraDataEntity: studentExtraData != null
          ? StudentExtraDataModel.fromJson(studentExtraData!).toEntity()
          : null,
      teacherExtraDataEntity: teacherExtraData != null
          ? TeacherExtraDataModel.fromJson(teacherExtraData!).toEntity()
          : null,
      address: address,
      phoneNumber: phoneNumber,
      gender: gender,
      profilePicurl: profilePicurl,
      status: status,
      role: role,
      joinedDate: joinedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'teacherExtraData': teacherExtraData,
      'address': address,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'profilePicurl': profilePicurl,
      'status': status,
      'role': role,
      'deviceId': deviceId,
      'joinedDate': joinedDate,
      'studentExtraData': studentExtraData,
    };
  }
}
