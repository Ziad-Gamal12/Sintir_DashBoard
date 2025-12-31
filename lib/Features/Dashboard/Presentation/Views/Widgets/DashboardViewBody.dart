import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_most_viewed_courses_cubit/dashbaord_most_viewed_courses_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_transactions_analytics_cubit/dashbaord_transactions_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_users_gender_analytics_cubit/dashbaord_users_gender_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardFetchHandler.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashbaordAnalyticsCubit>(
          create: (context) => DashbaordAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          ),
        ),
        BlocProvider(
          create: (context) => DashbaordMostViewedCoursesCubit(
            coursesrepo: getIt<Coursesrepo>(),
          ),
        ),
        BlocProvider<DashbaordTransactionsAnalyticsCubit>(
          create: (_) => DashbaordTransactionsAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          ),
        ),
        BlocProvider<DashbaordUsersGenderAnalyticsCubit>(
          create: (_) => DashbaordUsersGenderAnalyticsCubit(
            dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
          ),
        ),
      ],
      child: DashboardFetchHandler(),
    );
  }
}
