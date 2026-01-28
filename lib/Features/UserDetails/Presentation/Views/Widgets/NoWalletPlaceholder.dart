import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/constant.dart';

class NoWalletPlaceholder extends StatelessWidget {
  const NoWalletPlaceholder({super.key, required this.onAddPressed});
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: KMainColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KMainColor.withOpacity(0.1), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KMainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.wallet,
              color: KMainColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text("لا توجد محفظة نشطة", style: textStyles.bold20),
          const SizedBox(height: 12),
          Text(
            "هذا المستخدم ليس لديه محفظة حالياً. يمكنك إنشاء محفظة جديدة للبدء في تتبع الأرباح والمدفوعات.",
            textAlign: TextAlign.center,
            style: textStyles.regular14.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Custombutton(
            text: "إنشاء محفظة الآن",
            color: KMainColor,
            textColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            onPressed: onAddPressed,
            width: 250,
          ),
        ],
      ),
    );
  }
}
