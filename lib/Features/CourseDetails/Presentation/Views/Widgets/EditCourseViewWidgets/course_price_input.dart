import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CoursePriceInput extends StatelessWidget {
  final TextEditingController controller;

  const CoursePriceInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: "سعر الدورة",
      obscureText: false,
      textInputType: TextInputType.number,
      validator: (value) =>
          value == null || value.isEmpty ? "ادخل سعر الدورة" : null,
    );
  }
}
