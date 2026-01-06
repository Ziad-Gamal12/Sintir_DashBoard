import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CourseTitleInput extends StatelessWidget {
  final TextEditingController controller;

  const CourseTitleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: "اسم الدورة",
      obscureText: false,
      textInputType: TextInputType.text,
      validator: (value) =>
          value == null || value.isEmpty ? "اسم الدورة مطلوب" : null,
    );
  }
}
