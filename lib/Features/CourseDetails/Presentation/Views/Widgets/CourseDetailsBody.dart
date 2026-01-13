import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: Provider.value(
        value: course,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: CourseDetailsHeader()),
            SliverToBoxAdapter(child: Divider(height: 48)),
            BlocProvider(
              create: (context) => CourseAnalyticsCubit(
                courseAnalyticsRepo: getIt<CourseAnalyticsRepo>(),
              ),
              child: CourseDetailsSummaryCardsGrid(courseId: course.id),
            ),
            SliverToBoxAdapter(child: Divider(height: 48)),
            SliverToBoxAdapter(
              child: CourseDetailsSectionAndInstructorLayoutBuilder(
                course: course,
              ),
            ),

            SliverToBoxAdapter(child: Divider(height: 48)),
            SliverToBoxAdapter(
              child: CourseAnalyticsAndEngagementAdaptiveLayout(course: course),
            ),
          ],
        ),
      ),
    );
  }
}
