import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Managers/Custom_reset_password_cubit/Custom_reset_password_cubit.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomResetPasswordViewBodyActionButton extends StatelessWidget {
  const CustomResetPasswordViewBodyActionButton({
    super.key,
    required this.resetPasswordFormKey,
    required this.emailController,
  });

  final GlobalKey<FormState> resetPasswordFormKey;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return // Send Button
    BlocBuilder<CustomResetPasswordCubit, CustomResetPasswordState>(
      builder: (context, state) {
        final isLoading = state is CustomResetPasswordLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Custombutton(
                  text: "ارسال",
                  color: KMainColor,
                  textColor: Colors.white,
                  onPressed: () {
                    if (resetPasswordFormKey.currentState!.validate()) {
                      context
                          .read<CustomResetPasswordCubit>()
                          .sendResetPasswordEmail(email: emailController.text);
                    }
                  },
                ),
        );
      },
    );
  }
}
