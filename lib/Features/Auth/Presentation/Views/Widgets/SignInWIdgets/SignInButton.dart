import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/cubit/sign_in_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignInCubit, SignInState, bool>(
      selector: (state) {
        return state is SignInLoading;
      },
      builder: (context, isLoading) {
        return Custom_Loading_Widget(
          isLoading: isLoading,
          child: Custombutton(
            text: "تسجيل الدخول",
            color: KMainColor,
            textColor: Colors.white,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<SignInCubit>().signIn(
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
          ),
        );
      },
    );
  }
}
