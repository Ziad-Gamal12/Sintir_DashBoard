import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/InfoHighlightIconCard.dart';

class CustomResetFeatureHeader extends StatelessWidget {
  const CustomResetFeatureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoHighlightIconCard(
          icon: FontAwesomeIcons.key,
          color: Colors.amberAccent,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تأمين حسابك",
                style: AppTextStyles(
                  context,
                ).semiBold16.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "في سينتير، نولي أمانك أولوية قصوى. إذا نسيت كلمة المرور، سنساعدك في استعادتها بخطوات آمنة ومشفرة تماماً.",
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
