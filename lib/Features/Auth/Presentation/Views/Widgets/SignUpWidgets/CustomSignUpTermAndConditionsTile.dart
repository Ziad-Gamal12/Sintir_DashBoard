import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCheckBox.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomSignUpTermAndConditionsTile extends StatefulWidget {
  const CustomSignUpTermAndConditionsTile({super.key, required this.onChanged});

  final ValueChanged<bool> onChanged;

  @override
  State<CustomSignUpTermAndConditionsTile> createState() =>
      _CustomSignUpTermAndConditionsTileState();
}

class _CustomSignUpTermAndConditionsTileState
    extends State<CustomSignUpTermAndConditionsTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Using the custom checkbox
        Customcheckbox(
          onChanged: (value) {
            setState(() {
              isChecked = value;
            });
            widget.onChanged(value);
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "أوافق على ",
                  style: AppTextStyles(
                    context,
                  ).regular13.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
                TextSpan(
                  text: "شروط الخدمة",
                  style: AppTextStyles(
                    context,
                  ).semiBold13.copyWith(color: KSecondaryColor),
                ),
                TextSpan(
                  text: " و ",
                  style: AppTextStyles(
                    context,
                  ).regular13.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
                TextSpan(
                  text: "سياسة الخصوصية",
                  style: AppTextStyles(
                    context,
                  ).semiBold13.copyWith(color: KSecondaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
