import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart'
    show CourseEntity;
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Helpers/ShowAddingNewSubscriberDialog.dart';
import 'package:sintir_dashboard/constant.dart';

class AddNewSubscribersActionButton extends StatelessWidget {
  const AddNewSubscribersActionButton({
    super.key,
    required this.theme,
    required this.course,
  });

  final ThemeData theme;
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canAddSubscriber = PermissionsManager.can(
      Permission.editCourse,
      role: user.role,
      status: user.status,
    );

    if (!canAddSubscriber) {
      return const SizedBox.shrink();
    }

    return Custombutton(
      text: "إضافة",
      color: KMainColor,
      textColor: Colors.white,
      onPressed: () {
        AddNewSubscribersDialogHelper.showAddingNewSubscriberDialog(
          context,
          course,
          theme,
        );
      },
    );
  }
}
