import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpSection.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpWelcomePlaceholder.dart';

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key});

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  UserEntity userEntity = UserEntity(
    uid: "",
    firstName: "",
    lastName: "",
    email: "",
    address: "",
    phoneNumber: "",
    deviceId: "",
    gender: "",
    profilePicurl: "https://cdn-icons-png.flaticon.com/128/15239/15239514.png",
    status: BackendEndpoints.pendingStatus,
    role: "",
    joinedDate: DateTime.now().toString(),
    fullName: "",
  );
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SignUpSection(user: userEntity)),
        SignUpWelcomePlaceholder(),
      ],
    );
  }
}
