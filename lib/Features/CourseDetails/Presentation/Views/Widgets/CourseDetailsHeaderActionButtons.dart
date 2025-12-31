import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/constant.dart';

class CourseDetailsHeaderActionButtons extends StatelessWidget {
  const CourseDetailsHeaderActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Custombutton(
            text: "",
            color: KMainColor.withOpacity(0.1),
            textColor: KMainColor,
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: KMainColor),
                const SizedBox(width: 8),
                Text("تعديل"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Custombutton(
            text: "",
            color: Colors.red.shade700,
            textColor: Colors.white,
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white),
                const SizedBox(width: 8),
                Text("حذف"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
