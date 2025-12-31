import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/widgets/AppCopyrightLabel.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/AppVersionLabel.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomEmailTextField.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomPasswordTextField.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/SignInCubit/sign_in_cubit.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/DonotHaveAccountLabel.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/ForgetPasswordLabel.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/SignInButton.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/SignInHeader.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/ResponsiveDashboardView.dart';
import 'package:sintir_dashboard/constant.dart';

class SignInSection extends StatefulWidget {
  const SignInSection({super.key});

  @override
  State<SignInSection> createState() => _SignInSectionState();
}

class _SignInSectionState extends State<SignInSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocListener<SignInCubit, SignInState>(
        listener: (context, state) {
          if (state is SignInSuccess) {
            GoRouter.of(context).go(ResponsiveDashboardView.routeName);
          } else if (state is SignInFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppDialogs.error(context, state.errMessage);
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignInHeader(),
            const SizedBox(height: 40),
            CustomEmailTextField(controller: _emailController),
            const SizedBox(height: 24),
            CustomPasswordTextField(controller: _passwordController),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: ForgetPasswordLabel(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: SignInButton(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
              ),
            ),
            Spacer(),
            DonotHaveAccountLabel(),
            SizedBox(height: 12),
            Align(alignment: Alignment.center, child: AppCopyrightLabel()),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: AppVersionLabel(version: currentVersion),
            ),
          ],
        ),
      ),
    );
  }
}
