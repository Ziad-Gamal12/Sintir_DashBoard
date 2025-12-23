import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/SignUpCubit/sign_up_cubit.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/CustomSignUpActionButton.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/CustomSignUpTermAndConditionsTile.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SelectUserRoleHeader.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignInPopupText.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpHeader.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpSelectUserRoleRow.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpTextFields.dart';

class SignUpSection extends StatefulWidget {
  const SignUpSection({super.key, required this.user});
  final UserEntity user;

  @override
  State<SignUpSection> createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<SignUpSection> {
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isTermsAccepted = false;
  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          AppDialogs.success(
            context,
            "تم إرسال طلب التسجيل و سيتم مراجعةه من قبل المسؤول",
            onTap: () {
              GoRouter.of(context).pop();
            },
          );
        } else if (state is SignUpFailure) {
          AppDialogs.error(context, state.errMessage);
        }
      },
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.horizontal(context),
              vertical: AppPadding.vertical(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignUpHeader(),
                SizedBox(height: 48),
                SelectUserRoleHeader(),
                SizedBox(height: 24),
                SignUpSelectUserRoleRow(
                  onRoleSelected: (roleKey) {
                    widget.user.role = roleKey;
                    setState(() {});
                  },
                ),
                SizedBox(height: 24),
                SignUpTextFields(
                  userEntity: widget.user,
                  passwordController: passwordController,
                ),
                SizedBox(height: 24),
                CustomSignUpTermAndConditionsTile(
                  onChanged: (value) {
                    setState(() {
                      isTermsAccepted = value;
                    });
                  },
                ),
                SizedBox(height: 48),
                CustomSignUpActionButton(
                  formKey: formKey,
                  isTermsAccepted: isTermsAccepted,
                  userEntity: widget.user,
                  passwordController: passwordController,
                ),
                SizedBox(height: 24),
                SignInPopupText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
