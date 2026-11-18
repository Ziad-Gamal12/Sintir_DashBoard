import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';

class CourseDeclineReasonInput extends StatelessWidget {
  const CourseDeclineReasonInput({super.key, required this.controller});

  final TextEditingController controller;

  static const int minLength = 10;
  static const int maxLength = 1000;

  static String? validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < minLength) {
      return "اكتب سببًا واضحًا للرفض ($minLength أحرف على الأقل)";
    }
    if (text.length > maxLength) {
      return "سبب الرفض أطول من $maxLength حرف";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "سبب الرفض (يظهر للمدرس داخل التطبيق)",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          key: const ValueKey('course-decline-reason-input'),
          controller: controller,
          maxLines: 4,
          hintText: "مثال: صورة الغلاف غير واضحة، والوصف لا يذكر محتوى الدروس.",
          obscureText: false,
          textInputType: TextInputType.multiline,
          validator: validate,
        ),
      ],
    );
  }
}
