import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/add_subscribers_to_course_cubit/add_subscribers_to_course_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/UserSelectionDialog.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';

class AddNewSubscribersDialogHelper {
  static void showAddingNewSubscriberDialog(
    BuildContext context,
    CourseEntity course,
    ThemeData theme,
  ) {
    // Get the screen width to determine responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            child: Container(
              height: double.infinity,
              width: _calculateResponsiveWidth(screenWidth),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        UsersManagementCubit(usersRepo: getIt<UsersRepo>()),
                  ),
                  BlocProvider(
                    create: (context) => AddSubscribersToCourseCubit(
                      courseSubscibtionsRepo: getIt<CourseSubscibtionsRepo>(),
                    ),
                  ),
                ],
                child: UserSelectionDialog(courseEntity: course),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  /// Calculates the width based on standard breakpoints
  static double _calculateResponsiveWidth(double screenWidth) {
    if (screenWidth < 600) {
      return screenWidth * 0.9;
    } else if (screenWidth < 1200) {
      return screenWidth * 0.5;
    } else {
      return 500.0;
    }
  }
}
