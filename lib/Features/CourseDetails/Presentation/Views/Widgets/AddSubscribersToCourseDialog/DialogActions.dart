import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/add_subscribers_to_course_cubit/add_subscribers_to_course_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class DialogActions extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onConfirm;

  const DialogActions({
    super.key,
    required this.selectedCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("اغلاق"),
        ),
        const SizedBox(width: 12),
        BlocSelector<
          AddSubscribersToCourseCubit,
          AddSubscribersToCourseState,
          bool
        >(
          selector: (state) {
            return state is AddSubscribersToCourseLoading;
          },
          builder: (context, isLoading) {
            return Custom_Loading_Widget(
              isLoading: isLoading,
              child: Custombutton(
                text: "إضافة $selectedCount مستخدمين",
                onPressed: selectedCount == 0
                    ? null
                    : () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                color: KMainColor,
                textColor: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
