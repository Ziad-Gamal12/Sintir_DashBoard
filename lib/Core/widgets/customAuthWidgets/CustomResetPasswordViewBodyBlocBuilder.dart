import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPassCard.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPassIcon.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPasswordViewBodyDescription.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPasswordViewBodyPopUpButton.dart';

class CustomResetPasswordViewBodyBlocBuilder extends StatefulWidget {
  const CustomResetPasswordViewBodyBlocBuilder({super.key});

  @override
  State<CustomResetPasswordViewBodyBlocBuilder> createState() =>
      _CustomResetPasswordViewBodyBlocBuilderState();
}

class _CustomResetPasswordViewBodyBlocBuilderState
    extends State<CustomResetPasswordViewBodyBlocBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late TextEditingController emailController;
  late GlobalKey<FormState> key;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    key = GlobalKey<FormState>();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fade,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const CustomResetPassIcon(),

                  const SizedBox(height: 35),

                  // Title
                  Text(
                    "إعادة تعيين كلمة المرور",
                    style: AppTextStyles(context).semiBold24,
                  ),

                  const SizedBox(height: 14),

                  // Description
                  const CustomResetPasswordViewBodyDescription(),

                  const SizedBox(height: 40),

                  CustomResetPassCard(emailController: emailController),

                  const SizedBox(height: 40),

                  const CustomResetPasswordViewBodyPopUpButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
