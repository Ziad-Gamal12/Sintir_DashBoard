import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/SignUpCubit/sign_up_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomSignUpActionButton extends StatelessWidget {
  const CustomSignUpActionButton({
    super.key,
    required this.userEntity,
    required this.passwordController,
    required this.formKey,
    required this.isTermsAccepted,
  });
  final UserEntity userEntity;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool isTermsAccepted;
  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, bool>(
      selector: (state) {
        return state is SignUpLoading;
      },
      builder: (context, isLoading) {
        return Custom_Loading_Widget(
          isLoading: isLoading,
          child: Custombutton(
            text: "إنشاء حساب",
            color: KMainColor,
            textColor: Colors.white,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                userEntity.fullName =
                    "${userEntity.firstName} ${userEntity.lastName}";
                if (userEntity.role.isNotEmpty) {
                  if (isTermsAccepted) {
                    context.read<SignUpCubit>().signUp(
                      user: userEntity,
                      password: passwordController.text,
                    );
                  } else {
                    AppDialogs.warning(context, "يجب قبول الشروط والاحكام");
                  }
                } else {
                  AppDialogs.warning(context, "يرجى تحديد نوع الحساب");
                }
              }
            },
          ),
        );
      },
    );
  }
}
