import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/UpdateCourseCubit/UpdateCourseCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CourseInputsCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomAddCourseActionButton.dart';

class EditCourseViewBody extends StatefulWidget {
  const EditCourseViewBody({super.key, required this.currentCourse});
  final CourseEntity currentCourse;
  @override
  State<EditCourseViewBody> createState() => _EditCourseViewBodyState();
}

class _EditCourseViewBodyState extends State<EditCourseViewBody> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? selectedLanguage;
  String? selectedLevel;
  String? selectedSubject;
  String? selectedState;
  @override
  void initState() {
    super.initState();
    titleController.text = widget.currentCourse.title;
    codeController.text = widget.currentCourse.id;
    descriptionController.text = widget.currentCourse.description;
    priceController.text = widget.currentCourse.price.toString();
    selectedLanguage = widget.currentCourse.language;
    selectedLevel = widget.currentCourse.level;
    selectedSubject = widget.currentCourse.subject;
    selectedState = widget.currentCourse.state;
  }

  @override
  void dispose() {
    titleController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateCourseCubit, UpdateCourseCubitState>(
      listener: (context, state) {
        if (state is UpdateCourseCubitLoading) {
          AppDialogs.success(
            context,
            "تم تحديث الدورة بنجاح",
            onTap: () => GoRouter.of(context).pop(),
          );
        }
        if (state is UpdateCourseCubitFailure) {
          AppDialogs.error(context, state.errmessage);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                SizedBox(height: 20),
                CourseInputsCard(
                  titleController: titleController,
                  codeController: codeController,
                  courseEntity: widget.currentCourse,
                  descriptionController: descriptionController,
                  priceController: priceController,
                  posterurl: widget.currentCourse.posterUrl,
                  onStateChange: (value) => setState(() {
                    selectedState = value;
                  }),
                  onLevelChange: (v) => setState(() => selectedLevel = v),
                  onSubjectChange: (v) => setState(() => selectedSubject = v),
                  onLanguageChange: (v) => setState(() => selectedLanguage = v),
                ),
                const SizedBox(height: 50),
                CustomAddCourseActionButton(
                  formKey: formKey,
                  titleController: titleController,
                  codeController: codeController,
                  descriptionController: descriptionController,
                  priceController: priceController,
                  selectedLanguage: selectedLanguage,
                  selectedLevel: selectedLevel,
                  selectedSubject: selectedSubject,
                  currentCourse: widget.currentCourse,
                  selectedState: selectedState,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
