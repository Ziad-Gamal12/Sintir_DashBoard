import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomAddCourseShadowButton extends StatelessWidget {
  const CustomAddCourseShadowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: KMainColor.withOpacity(0.2),
              blurRadius: 16,
              offset: Offset(8, 8),
            ),
          ],
        ),
        child: Custombutton(
          text: "اضافة كورس",
          color: KMainColor,
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
