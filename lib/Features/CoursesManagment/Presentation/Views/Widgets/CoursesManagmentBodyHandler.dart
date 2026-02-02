import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CustomCourseTable.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Manager/courses_management_cubit/courses_management_cubit.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentHeader.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CustomFilterCoursesSection.dart';

class CoursesManagmentBodyHandler extends StatefulWidget {
  const CoursesManagmentBodyHandler({super.key});

  @override
  State<CoursesManagmentBodyHandler> createState() =>
      _CoursesManagmentBodyHandlerState();
}

class _CoursesManagmentBodyHandlerState
    extends State<CoursesManagmentBodyHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CoursesManagementCubit>().getCourses(isPaginate: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: CoursesManagmentHeader()),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(
            child: CustomFilterCoursesSection(
              onFilterChanged: (val) {
                context.read<CoursesManagementCubit>().filterCourses(
                  filters: val,
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: Divider(height: 48)),
          BlocBuilder<CoursesManagementCubit, CoursesManagementState>(
            builder: (context, state) {
              final cubit = context.read<CoursesManagementCubit>();
              bool isLoading = state is GetCoursesManagementCoursesLoading;
              if (state is GetCoursesManagementCoursesFailure &&
                  cubit.courses.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: CustomErrorWidget(errormessage: state.errmessage),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  height: 600,
                  child: ResponsiveCourseTable(
                    isLoading: isLoading,
                    onLoadMore: (rowIndex) {
                      if (cubit.hasMore && !isLoading) {
                        cubit.getCourses(isPaginate: true);
                      }
                    },
                    courses: cubit.courses,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
