import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/InfoHighlightIconCard.dart';

class CustomSignUpFeatureHeader extends StatelessWidget {
  const CustomSignUpFeatureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoHighlightIconCard(
          icon: FontAwesomeIcons.idBadge,
          color: Colors.cyanAccent,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الانضمام لفريق الإدارة",
                style: AppTextStyles(
                  context,
                ).semiBold16.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "مرحباً بك في لوحة تحكم سينتير. قم بإنشاء حسابك الإداري للبدء في إدارة المحتوى، متابعة المستخدمين، والإشراف على سير العمل.",
                style: AppTextStyles(context).regular13.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
