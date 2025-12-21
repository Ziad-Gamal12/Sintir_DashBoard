import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/Widgets/SplashViewBody.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  static const String routeName = '/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SplashViewBody());
  }
}
