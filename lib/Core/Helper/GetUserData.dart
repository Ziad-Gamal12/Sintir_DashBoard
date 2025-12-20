// ignore_for_file: file_names

import 'dart:convert';

import 'package:sintir_dashboard/Core/Services/HiveService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/UserModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

UserEntity getUserData() {
  String userJsonString = Hive_Services.stringGetter(
    key: BackendEndpoints.storeUserLocaly,
  );
  if (userJsonString == " ") {
    return UserEntity.empty();
  } else {
    Map<String, dynamic> userJson = jsonDecode(userJsonString);
    UserEntity userEntity = UserModel.fromJson(userJson).toEntity();
    return userEntity;
  }
}
