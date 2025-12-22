import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/InfoHighlightIconCard.dart';

class CustomSignInFeatureListTIle extends StatelessWidget {
  const CustomSignInFeatureListTIle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoHighlightIconCard(
          icon: FontAwesomeIcons.tableCellsLarge,
          color: Colors.amberAccent,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "إدارة شاملة للمنصة",
                style: AppTextStyles(
                  context,
                ).semiBold16.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "تحكم كامل في منصة سينتير التعليمية؛ من إدارة المحتوى والمستخدمين إلى متابعة الإحصائيات التقنية، كل ذلك من واجهة واحدة متكاملة.",
                style: AppTextStyles(context).regular13.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
