import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomEmailTextField.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPasswordViewBodyActionButton.dart';

class CustomResetPassCard extends StatefulWidget {
  const CustomResetPassCard({super.key, required this.emailController});
  final TextEditingController emailController;
  @override
  State<CustomResetPassCard> createState() => _CustomResetPassCardState();
}

class _CustomResetPassCardState extends State<CustomResetPassCard> {
  late GlobalKey<FormState> key;
  @override
  void initState() {
    super.initState();
    key = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey.withOpacity(.2), Colors.grey.withOpacity(.1)]
              : [Colors.white.withOpacity(.8), Colors.white.withOpacity(.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(.05),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: key,
        child: Column(
          children: [
            // Email field
            CustomEmailTextField(controller: widget.emailController),
            const SizedBox(height: 28),
            CustomResetPasswordViewBodyActionButton(
              emailController: widget.emailController,
              resetPasswordFormKey: key,
            ),
          ],
        ),
      ),
    );
  }
}
