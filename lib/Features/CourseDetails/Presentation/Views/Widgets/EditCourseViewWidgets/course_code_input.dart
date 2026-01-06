import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CourseCodeInput extends StatelessWidget {
  final TextEditingController controller;

  const CourseCodeInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: "كود الدورة",
      obscureText: false,
      textInputType: TextInputType.text,
      validator: (v) => v == null || v.isEmpty ? "كود الدورة مطلوب" : null,
    );
  }
}
