import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSectionsRepos/CourseSectionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseAnalyticsCubit/course_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSummaryCardsGrid.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCoursDetailsSectionCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCoursesInstructorSectionCard.dart';

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
            BlocProvider(
              create: (context) =>
                  CourseSectionsCubit(getIt<CourseSectionsRepo>()),
              child: SliverToBoxAdapter(
                child: CustomCoursDetailsSectionCard(course: course),
              ),
            ),
            SliverToBoxAdapter(child: Divider(height: 48)),

            BlocProvider(
              create: (context) => ContentCreatorCoursesCubit(
                contentCreatorProfileRepo: getIt<ContentCreatorProfileRepo>(),
              ),
              child: SliverToBoxAdapter(
                child: course.contentcreaterentity != null
                    ? ContentCreatorDetails(
                        contentcreaterentity: course.contentcreaterentity!,
                      )
                    : Placeholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
