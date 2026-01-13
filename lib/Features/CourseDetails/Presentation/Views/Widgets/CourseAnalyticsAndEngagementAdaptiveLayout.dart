import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseReportsRepo/CourseReportsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseTransactionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseReportsCubit/course_reports_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribtionsCubit/CourseSubscribtionsCubit.dart'; // Added
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_transactions_cubit/course_transactions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseReportsSectionCardWidgets/CustomCourseReportsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CourseSubscribersSectionCard.dart'; // Added
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/CustomCourseTransactionsCard.dart';

class CourseAnalyticsAndEngagementAdaptiveLayout extends StatelessWidget {
  const CourseAnalyticsAndEngagementAdaptiveLayout({
    super.key,
    required this.course,
  });

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
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
        // Added the Subscribers Cubit here
        BlocProvider(
          create: (context) => CourseSubscribtionsCubit(
            subscribtionRepo: getIt<CourseSubscibtionsRepo>(),
          )..getCoursSubscribers(courseID: course.id, isPaginate: false),
        ),
      ],
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
        final subscribers = CourseSubscribersSectionCard(
          key: const PageStorageKey('sub_card'),
          courseId: courseId,
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
                  transactions,
                  const SizedBox(height: 16),
                  subscribers,
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: feedbacks),
                  const SizedBox(width: 16),
                  Expanded(child: reports),
                ],
              ),
            ],
          );
        }
        // Mobile: Narrow Screens
        else {
          return Column(
            children: [
              transactions,
              const SizedBox(height: 16),
              subscribers,
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
