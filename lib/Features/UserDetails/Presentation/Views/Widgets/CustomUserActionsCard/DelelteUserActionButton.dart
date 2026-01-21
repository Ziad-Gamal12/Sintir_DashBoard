import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';

class DelelteUserActionButton extends StatelessWidget {
  const DelelteUserActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);

    return Custombutton(
      text: "",
      color: Colors.red.withOpacity(.1),
      textColor: Colors.red,
      onPressed: () {
        AppDialogs.warning(
          context,
          "هل أنت متأكد من رغبتك في حذف هذا المستخدم؟ هذا الإجراء لا يمكن التراجع عنه.",
          onTap: () {},
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "حذف المستخدم",
            style: textStyles.regular14.copyWith(color: Colors.red.shade700),
          ),
          Icon(Icons.delete, color: Colors.red.shade700),
        ],
      ),
    );
  }
}
