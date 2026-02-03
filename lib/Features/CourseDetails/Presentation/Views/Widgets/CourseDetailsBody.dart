import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseAnalyticsCubit/course_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseAnalyticsAndEngagementAdaptiveLayout.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSectionAndInstructorAndActionsLayoutBuilder.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSummaryCardsSection/CourseDetailsSummaryCardsGrid.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsViewHeaderWidgets/CourseDetailsHeader.dart';

class CourseDetailsBody extends StatelessWidget {
  const CourseDetailsBody({super.key, required this.course});
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canViewAnalytics = PermissionsManager.can(
      Permission.viewCourses,
      role: user.role,
      status: user.status,
    );
    if (!canViewAnalytics) {
      return AccessDeniedWidgetAr(featureNameAr: "عرض تحليلات الكورس");
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: Provider.value(
        value: course,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: CourseDetailsHeader()),
            const SliverToBoxAdapter(child: Divider(height: 48)),
            if (canViewAnalytics)
              BlocProvider(
                create: (context) => CourseAnalyticsCubit(
                  courseAnalyticsRepo: getIt<CourseAnalyticsRepo>(),
                ), // Trigger fetch only if permitted
                child: CourseDetailsSummaryCardsGrid(courseId: course.id),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),

            if (canViewAnalytics)
              const SliverToBoxAdapter(child: Divider(height: 48)),

            // 3. Info Section: Always visible
            SliverToBoxAdapter(
              child: CourseDetailsSectionAndInstructorLayoutBuilder(
                course: course,
              ),
            ),

            if (canViewAnalytics) ...[
              const SliverToBoxAdapter(child: Divider(height: 48)),
              SliverToBoxAdapter(
                child: CourseAnalyticsAndEngagementAdaptiveLayout(
                  course: course,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
