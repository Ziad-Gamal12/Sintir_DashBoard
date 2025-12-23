import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class SignUpUserRoleEntity {
  final String role;
  final String value;
  final IconData icon;
  SignUpUserRoleEntity({
    required this.role,
    required this.value,
    required this.icon,
  });

  static List<SignUpUserRoleEntity> getItems() {
    return [
      SignUpUserRoleEntity(
        value: BackendEndpoints.coursesManagerrRole,
        role: "مدير محتوى",
        icon: FontAwesomeIcons.bookOpenReader,
      ),
      SignUpUserRoleEntity(
        value: BackendEndpoints.usersManagerrRole,
        role: "مدير مستخدمين",
        icon: FontAwesomeIcons.usersGear,
      ),
      SignUpUserRoleEntity(
        value: BackendEndpoints.supportRole,
        role: "دعم فني",
        icon: FontAwesomeIcons.headset,
      ),
    ];
  }
}
