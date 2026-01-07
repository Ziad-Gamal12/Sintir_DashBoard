import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomContentListViewitem.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseSectionsBuilder extends StatelessWidget {
  const CustomCourseSectionsBuilder({
    super.key,
    required this.course,
    required this.sections,
  });

  final CourseEntity course;
  final List<CourseSectionEntity> sections;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseSectionsCubit, CourseSectionsState>(
      buildWhen: (previous, current) {
        return current is GetCourseSectionsLoading ||
            current is GetCourseSectionsSuccess ||
            current is GetCourseSectionsFailure;
      },
      builder: (context, state) {
        if (state is GetCourseSectionsLoading && state.isPaginate == false) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        } else if (state is GetCourseSectionsFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else {
          if (state is GetCourseSectionsSuccess && sections.isEmpty) {
            return Center(
              child: CustomEmptyWidget(text: "لا يوجد محاضرات لهذا الكورس"),
            );
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: (state is GetCourseSectionsLoading && state.isPaginate)
                ? sections.length + 1
                : sections.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) => index == sections.length
                ? const Center(
                    child: CircularProgressIndicator(color: KMainColor),
                  )
                : CustomContentListViewItem(
                    course: course,
                    sectionItem: sections[index],
                  ),
          );
        }
      },
    );
  }
}
