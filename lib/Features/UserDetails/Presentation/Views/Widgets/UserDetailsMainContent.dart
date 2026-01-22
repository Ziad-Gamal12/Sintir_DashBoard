import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CustomCourseTable.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActivityCardIsRow.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SectionHeader.dart';

class UserDetailsMainContent extends StatelessWidget {
  const UserDetailsMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CustomUserActivityCardsRow(),
        const SectionDivider(),
        const SectionHeader(title: "كورسات المستخدم"),
        const SizedBox(height: 16),
        SizedBox(
          height: 550,
          child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
            buildWhen: (previous, current) {
              return current is GetUserEnrolledCoursesFailure ||
                  current is GetUserEnrolledCoursesLoading ||
                  current is GetUserEnrolledCoursesSuccess;
            },
            builder: (context, state) {
              if (state is GetUserEnrolledCoursesFailure) {
                return Center(
                  child: CustomErrorWidget(errormessage: state.errmessage),
                );
              }
              return ResponsiveCourseTable(
                isLoading: state is GetUserEnrolledCoursesLoading,
                courses: context.read<UserDetailsCubit>().userCourses,
              );
            },
          ),
        ),
      ],
    );
  }
}
