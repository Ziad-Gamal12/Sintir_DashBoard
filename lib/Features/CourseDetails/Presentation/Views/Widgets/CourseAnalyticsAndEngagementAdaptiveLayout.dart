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
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart'; // Added
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_transactions_cubit/course_transactions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseAdaptiveLayoutBody.dart';

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
          create: (context) => CourseSubscribersCubit(
            subscribtionRepo: getIt<CourseSubscibtionsRepo>(),
          )..getCoursSubscribers(courseID: course.id, isPaginate: false),
        ),
      ],
      child: CustomCourseAdaptiveLayoutBody(course: course),
    );
  }
}
