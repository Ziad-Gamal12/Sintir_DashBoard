import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SplashViewBodyDescription extends StatelessWidget {
  const SplashViewBodyDescription({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return SizedBox(
      width: mediaQuery.size.width / 2,
      child: Text(
        "منصة متكاملة تمنحك التحكم الكامل في كافة ميزات التطبيق، مع أدوات متقدمة لمتابعة البيانات، وإدارة المستخدمين، وتحليل الإحصائيات بدقة وسهولة.",
        style: AppTextStyles(context).regular11,
        maxLines: 3,
        textAlign: TextAlign.center,
      ),
    );
  }
}
