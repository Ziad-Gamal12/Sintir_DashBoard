import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_most_viewed_courses_cubit/dashbaord_most_viewed_courses_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_transactions_analytics_cubit/dashbaord_transactions_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_users_gender_analytics_cubit/dashbaord_users_gender_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/DesktopDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/MobileDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/TabletDashboardView.dart';

class ResponsiveDashboardView extends StatelessWidget {
  const ResponsiveDashboardView({super.key});
  static const routeName = '/dashboard';
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashbaordAnalyticsCubit>(
          create: (context) => DashbaordAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          )..fetchAll(),
        ),
        BlocProvider(
          create: (context) =>
              DashbaordMostViewedCoursesCubit(coursesrepo: getIt<Coursesrepo>())
                ..fetchMostViewedCourses(isPaginate: false),
        ),
        BlocProvider<DashbaordTransactionsAnalyticsCubit>(
          create: (_) => DashbaordTransactionsAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          )..fetchTransactionsAnalytics(),
        ),
        BlocProvider<DashbaordUsersGenderAnalyticsCubit>(
          create: (_) => DashbaordUsersGenderAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          )..analyzeUsersGender(),
        ),
      ],

      child: ResponsiveLayout(
        mobile: MobileDashboardView(),
        tablet: TabletDashboardView(),
        desktop: DesktopDashboardView(),
      ),
    );
  }
}
