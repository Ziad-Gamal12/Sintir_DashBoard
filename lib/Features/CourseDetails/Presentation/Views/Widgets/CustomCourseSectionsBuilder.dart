import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomContentListViewitem.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseSectionsBuilder extends StatelessWidget {
  const CustomCourseSectionsBuilder({super.key, required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseSectionsCubit, CourseSectionsState>(
      buildWhen: (previous, current) {
        return current is GetCourseSectionsLoading ||
            current is GetCourseSectionsSuccess ||
            current is GetCourseSectionsFailure;
      },
      builder: (context, state) {
        if (state is GetCourseSectionsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        } else if (state is GetCourseSectionsSuccess) {
          if (state.response.sections.isEmpty) {
            return Center(
              child: CustomEmptyWidget(text: "لا يوجد محاضرات لهذا الكورس"),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.response.sections.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) => CustomContentListViewItem(
              course: course,
              sectionItem: state.response.sections[index],
            ),
          );
        } else if (state is GetCourseSectionsFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
