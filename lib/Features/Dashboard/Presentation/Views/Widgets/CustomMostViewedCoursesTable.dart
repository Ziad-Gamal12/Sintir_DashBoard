import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CustomCourseTable.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_most_viewed_courses_cubit/dashbaord_most_viewed_courses_cubit.dart';

class CustomMostViewedCoursesTable extends StatefulWidget {
  const CustomMostViewedCoursesTable({super.key});

  @override
  State<CustomMostViewedCoursesTable> createState() =>
      _CustomMostViewedCoursesTableState();
}

class _CustomMostViewedCoursesTableState
    extends State<CustomMostViewedCoursesTable> {
  bool hasMore = true;
  void _fetchMoreCourses() {
    final dashbaordMostViewedCoursesCubit = context
        .read<DashbaordMostViewedCoursesCubit>();
    if (!hasMore ||
        dashbaordMostViewedCoursesCubit.state
            is! DashbaordFetchMostViewedCoursesSuccess) {
      return;
    }

    dashbaordMostViewedCoursesCubit.fetchMostViewedCourses(isPaginate: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      DashbaordMostViewedCoursesCubit,
      DashbaordMostViewedCoursesState
    >(
      builder: (context, state) {
        final fetchedCourses = context
            .read<DashbaordMostViewedCoursesCubit>()
            .fetchedCourses;
        if (state is DashbaordFetchMostViewedCoursesFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errorMessage),
          );
        } else {
          return SizedBox(
            height: 600,
            child: ResponsiveCourseTable(
              onLoadMore: (rowIndex) {
                _fetchMoreCourses();
              },
              isLoading: state is DashbaordFetchMostViewedCoursesLoading,
              courses: fetchedCourses,
            ),
          );
        }
      },
      listener: (context, state) {
        if (state is DashbaordFetchMostViewedCoursesSuccess) {
          hasMore = state.resonseEntity.hasMore;
        }
      },
    );
  }
}
