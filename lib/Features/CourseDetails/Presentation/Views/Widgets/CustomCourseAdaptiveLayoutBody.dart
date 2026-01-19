import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseReportsSectionCardWidgets/CustomCourseReportsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CourseSubscribersSectionCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/CustomCourseTransactionsCard.dart';

class CustomCourseAdaptiveLayoutBody extends StatelessWidget {
  const CustomCourseAdaptiveLayoutBody({super.key, required this.course});
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final transactions = CustomCourseTransactionsCard(
          key: const PageStorageKey('trans_card'),
          courseId: course.id,
        );
        final feedbacks = CustomCourseFeedBacksCard(
          key: const PageStorageKey('feed_card'),
          courseId: course.id,
        );
        final reports = CustomCourseReportsCard(
          key: const PageStorageKey('repo_card'),
          courseId: course.id,
        );
        final subscribers = CourseSubscribersSectionCard(
          key: const PageStorageKey('sub_card'),
          course: course,
        );

        if (constraints.maxWidth > 1300) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    transactions,
                    const SizedBox(height: 16),
                    subscribers,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [feedbacks, const SizedBox(height: 16), reports],
                ),
              ),
            ],
          );
        } else if (constraints.maxWidth > 800) {
          return Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subscribers,
                  const SizedBox(height: 16),

                  transactions,
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: feedbacks),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: reports),
                ],
              ),
            ],
          );
        }
        // Mobile: Narrow Screens
        else {
          return Column(
            children: [
              subscribers,
              const SizedBox(height: 16),
              transactions,
              const SizedBox(height: 16),
              feedbacks,
              const SizedBox(height: 16),
              reports,
            ],
          );
        }
      },
    );
  }
}
