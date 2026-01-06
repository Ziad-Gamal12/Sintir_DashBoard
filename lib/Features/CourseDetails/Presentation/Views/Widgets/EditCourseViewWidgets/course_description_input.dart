import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CourseDescriptionInput extends StatelessWidget {
  final TextEditingController controller;

  const CourseDescriptionInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      maxLines: 5,
      hintText: "وصف الدورة",
      obscureText: false,
      textInputType: TextInputType.text,
      validator: (value) =>
          value == null || value.isEmpty ? "وصف الدورة مطلوب" : null,
    );
  }
}
