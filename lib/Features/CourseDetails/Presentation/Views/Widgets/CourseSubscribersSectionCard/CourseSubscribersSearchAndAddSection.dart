import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/add_subscribers_to_course_cubit/add_subscribers_to_course_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/UserSelectionDialog.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CourseSubscribersSearchAndAddSection extends StatelessWidget {
  const CourseSubscribersSearchAndAddSection({
    super.key,
    required this.searchController,
    required this.course,
  });

  final TextEditingController searchController;
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomSearchTextField(
            controller: searchController,
            onChanged: (val) {
              context.read<CourseSubscribersCubit>().searchSubscribers(
                courseID: course.id,
                keyword: val,
                isPaginate: false,
              );
            },
          ),
        ),
        Spacer(),
        Expanded(
          child: Custombutton(
            text: "إضافة",
            color: KMainColor,
            textColor: Colors.white,
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Dismiss",
                barrierColor: Colors.black.withOpacity(
                  0.5,
                ), // Dims the dashboard
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, anim1, anim2) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width *
                            0.35, // Side panel width
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => UsersManagementCubit(
                                usersRepo: getIt<UsersRepo>(),
                              ),
                            ),
                            BlocProvider(
                              create: (context) => AddSubscribersToCourseCubit(
                                courseSubscibtionsRepo:
                                    getIt<CourseSubscibtionsRepo>(),
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
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: const Offset(0, 0),
                        ).animate(
                          CurvedAnimation(
                            parent: anim1,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
