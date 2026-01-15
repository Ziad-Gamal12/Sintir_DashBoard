import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/AddNewSubscribersActionButton.dart';

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
          child: AddNewSubscribersActionButton(theme: theme, course: course),
        ),
      ],
    );
  }
}
