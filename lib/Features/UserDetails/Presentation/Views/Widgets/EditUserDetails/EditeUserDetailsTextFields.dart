import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomEmailTextField.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';
import 'package:sintir_dashboard/Core/widgets/DatePickerField.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SIgnUpFirstAndLastNameTextField.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpUserGender.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomEducationLevelDropdownButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomSubjectDropdownButton.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/EditUserDetails/CustomUserStatusDropDownButton.dart';

class EditUserDetailsTextFields extends StatefulWidget {
  const EditUserDetailsTextFields({super.key, required this.user});
  final UserEntity user;

  @override
  State<EditUserDetailsTextFields> createState() =>
      _EditUserDetailsTextFieldsState();
}

class _EditUserDetailsTextFieldsState extends State<EditUserDetailsTextFields> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController teacherExperienceController;
  late TextEditingController phoneNumberController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber,
    );
    addressController = TextEditingController(text: widget.user.address);
    teacherExperienceController = TextEditingController(
      text: widget.user.teacherExtraDataEntity?.workExperience ?? "",
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    teacherExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        SignUpFirstAndLastNameTextField(
          userEntity: widget.user,
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        CustomEmailTextField(
          controller: emailController,
          onSaved: (value) => widget.user.email = value ?? "",
        ),
        CustomTextField(
          obscureText: false,

          hintText: "رقم الهاتف",
          controller: phoneNumberController,
          prefixIcon: Icons.phone,
          textInputType: TextInputType.phone,
          validator: (val) {
            if (val == null || val.isEmpty) return "رقم الهاتف مطلوب";
            if (val.length < 8) return "رقم هاتف غير صالح";
            return null;
          },
          onSaved: (val) => widget.user.phoneNumber = val?.trim() ?? "",
        ),

        CustomTextField(
          obscureText: false,

          hintText: "العنوان",
          controller: addressController,
          prefixIcon: Icons.location_on,
          textInputType: TextInputType.streetAddress,
          onSaved: (val) => widget.user.address = val?.trim() ?? "",
          validator: (val) =>
              (val == null || val.isEmpty) ? "العنوان مطلوب" : null,
        ),
        SignUpUserGender(userEntity: widget.user),

        if (widget.user.teacherExtraDataEntity != null)
          _buildTeacherFields()
        else if (widget.user.studentExtraDataEntity != null)
          _buildStudentFields(),

        CustomUserStatusDropDownButton(
          hint: widget.user.status,
          onChanged: (val) => widget.user.status = val ?? "",
        ),
      ],
    );
  }

  Widget _buildTeacherFields() {
    return Column(
      spacing: 16,
      children: [
        CustomTextField(
          hintText: "الخبره",
          obscureText: false,
          prefixIcon: Icons.work,
          controller: teacherExperienceController,
          textInputType: TextInputType.text,
          validator: (val) =>
              (val == null || val.isEmpty) ? "الخبره مطلوب" : null,
          onSaved: (val) =>
              widget.user.teacherExtraDataEntity?.workExperience = val ?? "",
        ),
        CustomSubjectDropdownButton(
          hintText: widget.user.teacherExtraDataEntity?.subject,
          onValueChange: (value) =>
              widget.user.teacherExtraDataEntity?.subject = value ?? "",
        ),
      ],
    );
  }

  Widget _buildStudentFields() {
    return Column(
      spacing: 16,
      children: [
        CustomEducationLevelDropdownButton(
          hintText: widget.user.studentExtraDataEntity?.educationLevel,
          onValueChange: (value) =>
              widget.user.studentExtraDataEntity?.educationLevel = value ?? "",
        ),
        DatePickerField(
          initialDate: widget.user.studentExtraDataEntity?.birthDate ?? "",
          onDateChanged: (value) =>
              widget.user.studentExtraDataEntity?.birthDate = value.toString(),
        ),
      ],
    );
  }
}
