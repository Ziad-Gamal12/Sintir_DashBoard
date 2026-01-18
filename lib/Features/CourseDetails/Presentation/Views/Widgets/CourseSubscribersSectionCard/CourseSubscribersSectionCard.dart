import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CourseSubscribersSearchAndAddSection.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CustomCourseSubscribersTable.dart';

class CourseSubscribersSectionCard extends StatefulWidget {
  const CourseSubscribersSectionCard({super.key, required this.course});
  final CourseEntity course;

  @override
  State<CourseSubscribersSectionCard> createState() =>
      _CourseSubscribersSectionCardState();
}

class _CourseSubscribersSectionCardState
    extends State<CourseSubscribersSectionCard> {
  bool isExpanded = false;
  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseSubscribersCubit>();
    return BlocListener<CourseSubscribersCubit, CourseSubscribersState>(
      listener: (context, state) {
        if (state is DeleteSubscriberFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is DeleteSubscriberSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم حذف المستخدم بنجاح",
            type: SnackType.success,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCourseSectionsCardHeader(title: "المشتركين"),
            const SizedBox(height: 24),
            CourseSubscribersSearchAndAddSection(
              searchController: searchController,
              course: widget.course,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 600,
              child: CustomCourseSubscribersTable(
                subscribers: cubit.subscribers,
                courseID: widget.course.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
