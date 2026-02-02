// ignore_for_file: file_names, camel_case_types
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/CustomResetPasswordView.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignInView.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignUpView.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/ContentCreatorProfile.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/ResponsiveCourseDeatilsView.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/ResponsiveCoursesManagmentView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/ResponsiveDashboardView.dart';
import 'package:sintir_dashboard/Features/Splash/Presentation/Views/SplashView.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/ResponsiveTicketsManagementView.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/SupportChatMobileView.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/ResponsiveUserDetailsView.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/ResponsiveUsersManagementView.dart';
import 'package:sintir_dashboard/core/widgets/AppErrorView.dart';

class App_router {
  static GoRouter router = GoRouter(
    initialLocation: SplashView.routeName,
    errorPageBuilder: (context, state) {
      return NoTransitionPage(
        key: state.pageKey,
        child: AppErrorView(exception: state.error),
      );
    },
    redirect: (context, state) async {
      final user = getUserData();
      final bool authenticated = await FirebaseAuthService().isLoggedIn();
      final String currentLocation = state.matchedLocation;
      if (currentLocation == SplashView.routeName) {
        return null;
      }
      final bool loggedIn =
          (user.uid.isNotEmpty &&
              user.status == BackendEndpoints.activeStatus) &&
          authenticated;
      final String loginPath = SignInView.routeName;
      final String dashboardPath = ResponsiveDashboardView.routeName;
      if (!loggedIn && currentLocation != loginPath) {
        return loginPath;
      }
      if (loggedIn && currentLocation == loginPath) {
        return dashboardPath;
      }

      return null;
    },
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
      GoRoute(
        path: ResponsiveUsersManagementView.routeName,
        builder: (context, state) => ResponsiveUsersManagementView(),
      ),
      GoRoute(
        path: ResponsiveUserDetailsView.routeName,
        builder: (context, state) =>
            ResponsiveUserDetailsView(uid: state.extra as String),
      ),
      GoRoute(
        path: ResponsiveTicketsManagementView.routeName,
        builder: (context, state) => ResponsiveTicketsManagementView(),
      ),
      GoRoute(
        path: ResponsiveSupportChatView.routeName,
        builder: (context, state) => ResponsiveSupportChatView(
          supportTicket: state.extra as SupportTicketEntity,
        ),
      ),
    ],
  );
}
