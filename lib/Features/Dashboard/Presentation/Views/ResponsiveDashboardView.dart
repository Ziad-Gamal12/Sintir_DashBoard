import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/DesktopDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/MobileDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/TabletDashboardView.dart';

class ResponsiveDashboardView extends StatelessWidget {
  const ResponsiveDashboardView({super.key});
  static const routeName = '/dashboard';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashbaordAnalyticsCubit(
        dashbaordAnalyticsRepo: getIt<DashbaordAnalyticsRepo>(),
      ),
      child: ResponsiveLayout(
        mobile: MobileDashboardView(),
        tablet: TabletDashboardView(),
        desktop: DesktopDashboardView(),
      ),
    );
  }
}
