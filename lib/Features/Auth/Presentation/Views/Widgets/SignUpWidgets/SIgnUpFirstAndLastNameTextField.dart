import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class SignUpFirstAndLastNameTextField extends StatelessWidget {
  SignUpFirstAndLastNameTextField({
    super.key,
    required this.userEntity,
    this.firstNameController,
    this.lastNameController,
  });
  TextEditingController? firstNameController, lastNameController;
  final UserEntity userEntity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: "الأسم الأول",
            obscureText: false,
            prefixIcon: Icons.person,
            controller: firstNameController,
            textInputType: TextInputType.text,
            onSaved: (val) {
              userEntity.firstName = val ?? "";
            },
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "الأسم الأول مطلوب";
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: CustomTextField(
            hintText: "الأسم الثاني",
            prefixIcon: Icons.person,
            controller: lastNameController,
            obscureText: false,
            textInputType: TextInputType.text,
            onSaved: (val) {
              userEntity.lastName = val ?? "";
            },
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "الأسم الثاني مطلوب";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
