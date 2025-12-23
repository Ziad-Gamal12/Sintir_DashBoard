import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Managers/SignInCubit/sign_in_cubit.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/SignInViewBody.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});
  static const routeName = '/SignInView';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInCubit(authRepo: getIt<AuthRepo>()),
      child: Scaffold(body: SafeArea(child: SignInViewBody())),
    );
  }
}
