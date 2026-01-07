// ignore_for_file: file_names, camel_case_types
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/CustomResetPasswordView.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignInView.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignUpView.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/ContentCreatorProfile.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/ResponsiveCourseDeatilsView.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/ResponsiveCoursesManagmentView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/ResponsiveDashboardView.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/SplashView.dart';

class App_router {
  static GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: SplashView.routeName,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: SignInView.routeName,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: SignUpView.routeName,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: CustomResetPasswordView.routeName,
        builder: (context, state) => const CustomResetPasswordView(),
      ),
      GoRoute(
        path: ResponsiveDashboardView.routeName,
        builder: (context, state) => const ResponsiveDashboardView(),
      ),
      GoRoute(
        path: ResponsiveCoursesManagmentView.routeName,
        builder: (context, state) => const ResponsiveCoursesManagmentView(),
      ),
      GoRoute(
        path: ResponsiveCourseDeatilsView.routeName,
        builder: (context, state) =>
            ResponsiveCourseDeatilsView(course: state.extra as CourseEntity),
      ),
      GoRoute(
        path: ContentCreatorProfile.routeName,
        builder: (context, state) => ContentCreatorProfile(
          contentcreaterentity: state.extra as ContentCreatorEntity,
        ),
      ),
    ],
  );
}
