import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class UserRoleBadgeEntity {
  final String title;
  final IconData icon;
  final Color color;

  const UserRoleBadgeEntity({
    required this.title,
    required this.icon,
    required this.color,
  });

  static UserRoleBadgeEntity getUserRoleBadgeEntity(String role) {
    if (role == BackendEndpoints.studentRole) {
      return const UserRoleBadgeEntity(
        title: "طالب",
        icon: Icons.school,
        color: Colors.blueGrey,
      );
    } else if (role == BackendEndpoints.teacherRole) {
      return const UserRoleBadgeEntity(
        title: "معلم",
        icon: Icons.work,
        color: Colors.blueGrey,
      );
    } else if (role == BackendEndpoints.coursesManagerrRole) {
      return const UserRoleBadgeEntity(
        title: "مدير محتوى",
        icon: Icons.book,
        color: Colors.blue,
      );
    } else if (role == BackendEndpoints.usersManagerrRole) {
      return const UserRoleBadgeEntity(
        title: "مدير مستخدمين",
        icon: Icons.person,
        color: Colors.green,
      );
    } else if (role == BackendEndpoints.supportRole) {
      return const UserRoleBadgeEntity(
        title: "دعم فني",
        icon: Icons.headset,
        color: Colors.yellow,
      );
    } else if (role == BackendEndpoints.adminRole) {
      return const UserRoleBadgeEntity(
        title: "مدير عام",
        icon: Icons.admin_panel_settings,
        color: Colors.purple,
      );
    } else {
      return const UserRoleBadgeEntity(
        title: "مستخدم",
        icon: Icons.person,
        color: Colors.grey,
      );
    }
  }
}
