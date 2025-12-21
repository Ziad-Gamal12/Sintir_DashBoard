import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
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
        padding: const EdgeInsets.symmetric(
          horizontal: KHorizontalPadding,
          vertical: KVerticalPadding,
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
            Text(
              "جميع الحقوق محفوظة لموقع سينتير 2026",
              style: AppTextStyles(
                context,
              ).regular10.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              currentVersion,
              style: AppTextStyles(
                context,
              ).regular10.copyWith(color: Colors.grey),
            ),
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
