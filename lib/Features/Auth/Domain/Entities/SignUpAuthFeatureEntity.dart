import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpAuthFeatureEntity {
  final IconData icon;
  final Color color;
  final String title, subtitle;

  SignUpAuthFeatureEntity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  static List<SignUpAuthFeatureEntity> getItems() {
    return [
      SignUpAuthFeatureEntity(
        icon: FontAwesomeIcons.userShield,
        color: const Color(0xFF69F0AE),
        title: "صلاحيات الوصول",
        subtitle: "نظام متطور لإدارة الأدوار وتحديد مهام كل موظف بدقة",
      ),
      SignUpAuthFeatureEntity(
        icon: FontAwesomeIcons.chartPie,
        color: Colors.cyanAccent,
        title: "تحليلات البيانات",
        subtitle: "الوصول إلى تقارير الأداء وتحليل البيانات لاتخاذ قرارات أفضل",
      ),
      SignUpAuthFeatureEntity(
        icon: FontAwesomeIcons.server,
        color: Colors.amberAccent,
        title: "إدارة النظام",
        subtitle: "مراقبة استقرار المنصة وإدارة المحتوى والعمليات اليومية",
      ),
    ];
  }
}
