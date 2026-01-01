import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsDescription.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCoursePoster.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseSectionsBuilder.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseSectionsCardHeader.dart';

class CustomCoursDetailsSectionCard extends StatefulWidget {
  const CustomCoursDetailsSectionCard({super.key, required this.course});

  final CourseEntity course;
  @override
  State<CustomCoursDetailsSectionCard> createState() =>
      _CustomCoursDetailsSectionCardState();
}

class _CustomCoursDetailsSectionCardState
    extends State<CustomCoursDetailsSectionCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CourseSectionsCubit>().getCourseSections(
        courseId: widget.course.id,
        isPaginate: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          CustomCoursePoster(),
          SizedBox(height: 32),
          CourseDetailsDescription(),
          Divider(height: 32),
          CustomCourseSectionsCardHeader(title: "المحاضرات", showMore: () {}),
          SizedBox(height: 32),
          CustomCourseSectionsBuilder(course: widget.course),
        ],
      ),
    );
  }
}
