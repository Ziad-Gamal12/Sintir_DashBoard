import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorCoursesGridDisplayedCourses.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorCoursesGridLoadingCourses.dart';
import 'package:sintir_dashboard/constant.dart';

class ContentCreatorCoursesGrid extends StatefulWidget {
  const ContentCreatorCoursesGrid({super.key});

  @override
  State<ContentCreatorCoursesGrid> createState() =>
      _ContentCreatorCoursesGridState();
}

class _ContentCreatorCoursesGridState extends State<ContentCreatorCoursesGrid> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentCreatorCoursesCubit, ContentCreatorCoursesState>(
      builder: (context, state) {
        if (state is GetContentCreatorCoursesLoading) {
          return const ContentCreatorCoursesGridLoadingCourses();
        } else if (state is GetContentCreatorCoursesFailure) {
          return SliverToBoxAdapter(
            child: Center(
              child: CustomErrorWidget(errormessage: state.errmessage),
            ),
          );
        } else if (state is GetContentCreatorCoursesSuccess &&
            state.coursesList.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: CustomEmptyWidget(text: "لا يوجد كورسات لهذا المعلم"),
            ),
          );
        } else if (state is GetContentCreatorCoursesSuccess &&
            state.coursesList.isNotEmpty) {
          return ContentCreatorCoursesGridDisplayedCourses(
            coursesList: state.coursesList,
          );
        } else {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: KMainColor)),
          );
        }
      },
    );
  }
}
