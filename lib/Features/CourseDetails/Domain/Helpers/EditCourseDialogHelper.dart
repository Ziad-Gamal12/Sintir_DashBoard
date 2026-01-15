import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/EditCourseView.dart';

class EditCourseDialogHelper {
  static void showResponsiveEditDialog(
    BuildContext context,
    CourseEntity course,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            child: Container(
              height: double.infinity,

              width: screenWidth < 600
                  ? screenWidth
                  : screenWidth < 1200
                  ? screenWidth * 0.5
                  : 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: EditCourseView(currentCourse: course),
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
}
