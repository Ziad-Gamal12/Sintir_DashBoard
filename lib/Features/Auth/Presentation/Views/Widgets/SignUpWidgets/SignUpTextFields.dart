import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomEmailTextField.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomPasswordTextField.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SIgnUpFirstAndLastNameTextField.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpUserGender.dart';

class SignUpTextFields extends StatelessWidget {
  const SignUpTextFields({
    super.key,
    required this.passwordController,
    required this.userEntity,
  });
  final TextEditingController passwordController;
  final UserEntity userEntity;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        SignUpFirstAndLastNameTextField(userEntity: userEntity),
        CustomEmailTextField(
          controller: null,
          onSaved: (value) {
            userEntity.email = value ?? "";
          },
        ),
        CustomTextField(
          hintText: "رقم الهاتف",
          prefixIcon: Icons.phone,
          obscureText: false,
          textInputType: TextInputType.phone,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "رقم الهاتف مطلوب";
            }
            return null;
          },
          onSaved: (val) {
            userEntity.phoneNumber = val ?? "";
          },
        ),
        CustomTextField(
          hintText: "العنوان بالتفصيل",
          prefixIcon: Icons.location_on,
          obscureText: false,
          textInputType: TextInputType.text,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "العنوان  مطلوب";
            }
            return null;
          },
          onSaved: (val) {
            userEntity.address = val ?? "";
          },
        ),
        SignUpUserGender(userEntity: userEntity),
        CustomPasswordTextField(controller: passwordController),
      ],
    );
  }
}
