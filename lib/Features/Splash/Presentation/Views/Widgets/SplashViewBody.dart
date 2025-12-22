import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/AppCopyrightLabel.dart';
import 'package:sintir_dashboard/Core/widgets/AppVersionLabel.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignInView.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/Widgets/SplashAppLogo.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/Widgets/SplashViewBodyDescription.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/Widgets/SplashViewBodyLoadingWidget.dart';
import 'package:sintir_dashboard/constant.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();
    initNavigator();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.horizontal(context),
          vertical: AppPadding.vertical(context),
        ),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            const Spacer(),
            SplashAppLogo(),
            SizedBox(height: 12),
            Text("SINTIR", style: AppTextStyles(context).bold24.copyWith()),
            SizedBox(height: 12),
            SplashViewBodyDescription(),
            const Spacer(),
            SplashViewBodyLoadingWidget(),
            SizedBox(height: 12),
            AppCopyrightLabel(),
            SizedBox(height: 8),
            AppVersionLabel(version: currentVersion),
          ],
        ),
      ),
    );
  }

  void initNavigator() async {
    bool isLogin = await FirebaseAuthService().isLoggedIn();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (isLogin) {
        // GoRouter.of(context).go(

        // );
      } else {
        GoRouter.of(context).go(SignInView.routeName);
      }
    });
  }
}
