import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/UpdateCourseCubit/UpdateCourseCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/EditCourseViewBody.dart';

class EditCourseView extends StatefulWidget {
  const EditCourseView({super.key, required this.currentCourse});
  static const routeName = '/Addcourseview';
  final CourseEntity currentCourse;
  @override
  State<EditCourseView> createState() => _EditCourseViewState();
}

class _EditCourseViewState extends State<EditCourseView> {
  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canEdit = PermissionsManager.can(
      Permission.editCourse,
      role: user.role,
      status: user.status,
    );

    if (!canEdit) {
      return const Scaffold(
        body: AccessDeniedWidgetAr(featureNameAr: "تعديل الكورس"),
      );
    }

    return BlocProvider(
      create: (context) => UpdateCourseCubit(
        coursesrepo: getIt<Coursesrepo>(),
        pickerAssetsInterface: getIt<PickerAssetsInterface>(),
      ),
      child: EditCourseViewBody(currentCourse: widget.currentCourse),
    );
  }
}
