import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseReportsCubit/course_reports_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseReportsSectionCardWidgets/CustomCourseReportsListView.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseReportsCard extends StatefulWidget {
  const CustomCourseReportsCard({super.key, required this.courseId});
  final String courseId;

  @override
  State<CustomCourseReportsCard> createState() =>
      _CustomCourseReportsCardState();
}

class _CustomCourseReportsCardState extends State<CustomCourseReportsCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseReportsCubit>();
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCourseSectionsCardHeader(
              title: "بلاغات الدورة",
              showMore: cubit.hasMore
                  ? () {
                      context.read<CourseReportsCubit>().getCourseReports(
                        isPaginate: true,
                        courseId: widget.courseId,
                      );
                    }
                  : null,
              action: IconButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                icon: Icon(
                  isExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: isExpanded ? KMainColor : theme.hintColor,
                ),
                tooltip: isExpanded ? "تصغير" : "توسيع",
              ),
            ),
            const SizedBox(height: 24),
            isExpanded ? _buildFullView(cubit) : _buildFixedView(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedView(CourseReportsCubit cubit) {
    return SizedBox(
      height: 450,
      child: CustomCourseReportsListView(
        reports: cubit.courseReports,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
      ),
    );
  }

  Widget _buildFullView(CourseReportsCubit cubit) {
    return CustomCourseReportsListView(
      reports: cubit.courseReports,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}
