import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorProfileBody.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomNavigateToInstructorProfileButton extends StatelessWidget {
  const CustomNavigateToInstructorProfileButton({
    super.key,
    required this.theme,
    required this.contentcreaterentity,
  });

  final ThemeData theme;
  final ContentCreatorEntity contentcreaterentity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          showInstructorProfile(context, contentcreaterentity);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle_outlined, color: KMainColor, size: 20),
              const SizedBox(width: 12),
              Text(
                "ملف المعلم",
                style: AppTextStyles(context).semiBold14.copyWith(
                  color: KMainColor, //
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showInstructorProfile(
    BuildContext context,
    ContentCreatorEntity entity,
  ) {
    ThemeData theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    double containerWidth;
    if (screenWidth < 600) {
      containerWidth = screenWidth * 0.85;
    } else if (screenWidth < 1100) {
      // Tablet/Small Laptop: Take 40%
      containerWidth = screenWidth * 0.4;
    } else {
      containerWidth = 450.0;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(
        0.4,
      ), // Dim the dashboard for focus
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: containerWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ), // Rounded edge for premium feel
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(-10, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                // Ensures content doesn't hit the edges
                child: BlocProvider(
                  create: (context) => ContentCreatorCoursesCubit(
                    contentCreatorProfileRepo:
                        getIt<ContentCreatorProfileRepo>(),
                  ),
                  child: ContentCreatorProfileBody(
                    contentcreaterentity:
                        entity, // Fixed variable name to match parameter
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: const Offset(0, 0),
              ).animate(
                CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutCubic, // Smoother transition
                ),
              ),
          child: child,
        );
      },
    );
  }
}
