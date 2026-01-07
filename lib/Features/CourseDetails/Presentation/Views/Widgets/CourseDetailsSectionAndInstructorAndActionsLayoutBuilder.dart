import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSectionsRepos/CourseSectionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_details_actions_cubit/course_details_actions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDeatilsActionsButtonsSectionCard/CustomCourseActionsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSectionCard/CourseDetailsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCoursDetailsSectionCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInstructorSectionCardWidgets/CustomCoursesInstructorSectionCard.dart';

class CourseDetailsSectionAndInstructorLayoutBuilder extends StatefulWidget {
  const CourseDetailsSectionAndInstructorLayoutBuilder({
    super.key,
    required this.course,
  });
  final CourseEntity course;
  @override
  State<CourseDetailsSectionAndInstructorLayoutBuilder> createState() =>
      CourseDetailsSectionAndInstructorLayoutBuilderState();
}

class CourseDetailsSectionAndInstructorLayoutBuilderState
    extends State<CourseDetailsSectionAndInstructorLayoutBuilder> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => CourseSectionsCubit(getIt<CourseSectionsRepo>())
            ..getCourseSections(courseId: widget.course.id, isPaginate: false),
        ),
        BlocProvider(
          lazy: false,
          create: (context) =>
              ContentCreatorCoursesCubit(
                contentCreatorProfileRepo: getIt<ContentCreatorProfileRepo>(),
              )..getContentCreatorCourses(
                userId: widget.course.contentcreaterentity!.id,
              ),
        ),
        BlocProvider(
          create: (context) =>
              CourseDetailsActionsCubit(coursesrepo: getIt<Coursesrepo>()),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                CustomCoursDetailsSectionCard(course: widget.course),
                Divider(height: 24),
                ContentCreatorDetailsCard(
                  contentcreaterentity: widget.course.contentcreaterentity!,
                ),
                Divider(height: 24),
                CourseDetailsCard(course: widget.course),
                Divider(height: 24),
                CustomCourseActionsCard(course: widget.course),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomCoursDetailsSectionCard(course: widget.course),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      ContentCreatorDetailsCard(
                        contentcreaterentity:
                            widget.course.contentcreaterentity!,
                      ),
                      const Divider(height: 24),
                      CourseDetailsCard(course: widget.course),
                      const Divider(height: 24),
                      CustomCourseActionsCard(course: widget.course),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
