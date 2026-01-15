import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart'
    show CourseEntity;
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
