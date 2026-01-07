import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseReportsRepo/CourseReportsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseTransactionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseReportsCubit/course_reports_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_transactions_cubit/course_transactions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseReportsSectionCardWidgets/CustomCourseReportsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/CustomCourseTransactionsCard.dart';

class CustomCourseTransactionsAndFeedbacksAndReportsSection
    extends StatelessWidget {
  const CustomCourseTransactionsAndFeedbacksAndReportsSection({
    super.key,
    required this.course,
  });

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    // 1. Providers live here. They are created ONCE when the section is loaded.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourseFeedBacksCubit(
            courseFeedBacksRepo: getIt<CourseFeedBacksRepo>(),
          )..getCourseFeedBacks(courseId: course.id, isPaginate: false),
        ),
        BlocProvider(
          create: (context) =>
              CourseReportsCubit(coursereportsrepo: getIt<CourseReportsRepo>())
                ..getCourseReports(courseId: course.id, isPaginate: false),
        ),
        BlocProvider(
          create: (context) => CourseTransactionsCubit(
            courseTransactionsRepo: getIt<CourseTransactionsRepo>(),
          )..fetchCourseTransactions(courseId: course.id, isPaginate: false),
        ),
      ],
      // 2. The Adaptive UI logic lives in a separate child widget
      child: CustomCourseAdaptiveLayoutBody(courseId: course.id),
    );
  }
}

class CustomCourseAdaptiveLayoutBody extends StatelessWidget {
  const CustomCourseAdaptiveLayoutBody({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final transactions = CustomCourseTransactionsCard(
          key: const PageStorageKey('trans_card'),
          courseId: courseId,
        );
        final feedbacks = CustomCourseFeedBacksCard(
          key: const PageStorageKey('feed_card'),
          courseId: courseId,
        );
        final reports = CustomCourseReportsCard(
          key: const PageStorageKey('repo_card'),
          courseId: courseId,
        );

        if (constraints.maxWidth > 1300) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: transactions),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: feedbacks),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: reports),
            ],
          );
        } else if (constraints.maxWidth > 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              transactions,
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: feedbacks),
                  const SizedBox(width: 16),
                  Expanded(child: reports),
                ],
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
