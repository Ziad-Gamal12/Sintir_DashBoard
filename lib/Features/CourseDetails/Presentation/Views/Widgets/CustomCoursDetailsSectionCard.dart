import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsDescription.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCoursePoster.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseSectionsBuilder.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseSectionsCardHeader.dart';

class CustomCoursDetailsSectionCard extends StatelessWidget {
  const CustomCoursDetailsSectionCard({super.key, required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseSectionsCubit>();
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: CustomCard(
        child: Column(
          children: [
            CustomCoursePoster(),
            SizedBox(height: 32),
            CourseDetailsDescription(),
            Divider(height: 32),
            CustomCourseSectionsCardHeader(
              title: "المحاضرات",
              showMore: () {
                if (cubit.hasMore &&
                    context.read<CourseSectionsCubit>().state
                        is! GetCourseSectionsLoading) {
                  context.read<CourseSectionsCubit>().getCourseSections(
                    courseId: course.id,
                    isPaginate: true,
                  );
                }
              },
            ),
            SizedBox(height: 32),
            Expanded(
              child: CustomCourseSectionsBuilder(
                course: course,
                sections: cubit.courseSections,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
