// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomPasswordVisibleIcon.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CustomPasswordTextField extends StatefulWidget {
  CustomPasswordTextField({super.key, this.controller, this.hintOrlabalText});
  TextEditingController? controller;
  String? hintOrlabalText;
  @override
  State<CustomPasswordTextField> createState() =>
      _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool ispasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      suffixIcon: Custompasswordvisibleicon(
        visibilityChanged: (isVisible) {
          setState(() {
            ispasswordVisible = isVisible;
          });
        },
      ),
      hintText: widget.hintOrlabalText ?? "كلمة المرور",
      obscureText: !ispasswordVisible,
      controller: widget.controller,
      textInputType: TextInputType.visiblePassword,
      prefixIcon: Icons.lock_outline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "كلمة المرور مطلوبة";
        } else if (value.length < 8) {
          return "كلمة المرور يجب ان تكون على الاقل 8 حروف";
        }
        return null;
      },
    );
  }
}
