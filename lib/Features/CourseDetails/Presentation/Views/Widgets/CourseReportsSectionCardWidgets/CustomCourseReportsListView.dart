import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseReportsCubit/course_reports_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseReportsSectionCardWidgets/CustomCourseReportsCardItem.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseReportsListView extends StatelessWidget {
  const CustomCourseReportsListView({
    super.key,
    required this.reports,
    this.shrinkWrap = false,
    this.physics = const BouncingScrollPhysics(),
  });

  final List<CourseReportEntity> reports;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseReportsCubit, CourseReportsState>(
      buildWhen: (previous, current) =>
          current is CourseReportsGetReportLoading ||
          current is CourseReportsGetReportSuccess ||
          current is CourseReportsGetReportFailure,
      builder: (context, state) {
        if (state is CourseReportsGetReportLoading && !state.isPaginate) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        } else if (state is CourseReportsGetReportFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else if (reports.isEmpty) {
          return const Center(
            child: CustomEmptyWidget(text: "لا يوجد بلاغات لهذا الكورس"),
          );
        }

        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount:
              (state is CourseReportsGetReportLoading && state.isPaginate)
              ? reports.length + 1
              : reports.length,
          itemBuilder: (context, index) {
            if (index == reports.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(color: KMainColor),
                ),
              );
            }
            return CustomCourseReportsCardItem(report: reports[index]);
          },
        );
      },
    );
  }
}
