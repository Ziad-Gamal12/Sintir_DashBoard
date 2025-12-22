import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInAuthFeatureEntity {
  final IconData icon;
  final Color color;
  final String title, subtitle;

  SignInAuthFeatureEntity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  static List<SignInAuthFeatureEntity> getItems() {
    return [
      SignInAuthFeatureEntity(
        icon: FontAwesomeIcons.graduationCap,
        color: Colors.amberAccent,
        title: "إدارة الدورات",
        subtitle: "تحكم كامل بالمحتوى التعليمي والمناهج",
      ),
      SignInAuthFeatureEntity(
        icon: FontAwesomeIcons.usersGear,
        color: Colors.cyanAccent,
        title: "إدارة المستخدمين",
        subtitle: "متابعة الطلاب، المدربين، وصلاحيات الوصول",
      ),
      SignInAuthFeatureEntity(
        icon: FontAwesomeIcons.headset,
        color: const Color(0xFF69F0AE),
        title: "الدعم الفني",
        subtitle: "حل المشكلات التقنية ومتابعة تذاكر الدعم",
      ),
    ];
  }
}
