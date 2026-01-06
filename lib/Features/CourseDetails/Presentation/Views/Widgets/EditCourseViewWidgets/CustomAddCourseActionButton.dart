import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/UpdateCourseCubit/UpdateCourseCubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomAddCourseActionButton extends StatelessWidget {
  const CustomAddCourseActionButton({
    super.key,
    required this.formKey,
    required this.selectedLevel,
    required this.selectedSubject,
    required this.titleController,
    required this.currentCourse,
    required this.codeController,
    required this.descriptionController,
    required this.priceController,
    required this.selectedLanguage,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final CourseEntity currentCourse;
  final String? selectedLevel;
  final String? selectedSubject;
  final String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UpdateCourseCubit, UpdateCourseCubitState, bool>(
      selector: (state) =>
          state is UpdateCourseCubitLoading ||
          state is UpdateCourseCubitAssetLoading,
      builder: (context, isLoading) {
        return Custom_Loading_Widget(
          isLoading: isLoading,
          child: Custombutton(
            text: "تحديث الدورة",
            color: KMainColor,
            textColor: Colors.white,
            onPressed: isLoading ? () {} : () => _submitCourse(context),
          ),
        );
      },
    );
  }

  void _showMissingFieldsDialog(BuildContext context) {
    AppDialogs.error(context, "يرجى ملء جميع الحقول المطلوبة");
  }

  void _showMissingImageDialog(BuildContext context) {
    AppDialogs.error(context, "يرجى اختيار صورة للدورة");
  }

  void _showInvalidPriceDialog(BuildContext context) {
    AppDialogs.error(context, "يرجى ادخال قيمة صحيحة للسعر");
  }

  void _submitCourse(BuildContext context) {
    FocusScope.of(context).unfocus();

    final cubit = context.read<UpdateCourseCubit>();

    if (!formKey.currentState!.validate()) return;

    if (selectedLevel == null ||
        selectedSubject == null ||
        selectedLanguage == null) {
      _showMissingFieldsDialog(context);
      return;
    }

    if (cubit.coursePosterImage == null) {
      _showMissingImageDialog(context);
      return;
    }

    final priceText = priceController.text.trim();
    final price = int.tryParse(priceText);
    if (price == null || price < 0) {
      _showInvalidPriceDialog(context);
      return;
    }
    final course = CourseEntity(
      studentsCount: currentCourse.studentsCount,
      contentcreaterentity: currentCourse.contentcreaterentity,
      posterUrl: currentCourse.posterUrl,
      subject: selectedSubject!,
      id: codeController.text.trim(),
      level: selectedLevel!,
      state: BackendEndpoints.coursePendingState,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: price,
      language: selectedLanguage!,
      postedDate: DateTime.now(),
    );
    cubit.update(courseEntity: course);
  }
}
