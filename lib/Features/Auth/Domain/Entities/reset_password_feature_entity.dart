import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResetPasswordFeatureEntity {
  final IconData icon;
  final Color color;
  final String title, subtitle;

  ResetPasswordFeatureEntity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  static List<ResetPasswordFeatureEntity> getItems() {
    return [
      ResetPasswordFeatureEntity(
        icon: FontAwesomeIcons.shieldHalved,
        color: const Color(0xFF69F0AE), // Success Green
        title: "حماية الحساب",
        subtitle: "نستخدم أعلى معايير التشفير لضمان أمان بياناتك الشخصية",
      ),
      ResetPasswordFeatureEntity(
        icon: FontAwesomeIcons.envelopeOpenText,
        color: Colors.cyanAccent,
        title: "تأكيد الهوية",
        subtitle: "يتم إرسال رمز التحقق مباشرة إلى بريدك الإلكتروني المسجل",
      ),
      ResetPasswordFeatureEntity(
        icon: FontAwesomeIcons.lockOpen,
        color: Colors.amberAccent,
        title: "استعادة الوصول",
        subtitle: "خطوات بسيطة وسريعة لتعيين كلمة مرور جديدة وقوية",
      ),
    ];
  }
}
