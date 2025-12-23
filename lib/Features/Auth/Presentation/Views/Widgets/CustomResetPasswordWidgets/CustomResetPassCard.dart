import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomEmailTextField.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/CustomResetPasswordWidgets/CustomResetPasswordViewBodyActionButton.dart';

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
    ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
