import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/SignUpCubit/sign_up_cubit.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpViewBody.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});
  static String routeName = '/signUpView';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(authRepo: getIt<AuthRepo>()),
      child: Scaffold(body: SafeArea(child: SignUpViewBody())),
    );
  }
}
