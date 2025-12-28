import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CourseInfo extends StatelessWidget {
  const CourseInfo({super.key, required this.course});
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 48,
            height: 48,
            color: Colors.blue.withOpacity(0.1),
            child: CustomCachedNetworkImage(imageUrl: course.posterUrl ?? ''),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: textStyles.semiBold14,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course.id.length > 10
                    ? "${course.id.substring(0, 10)}..."
                    : course.id,
                style: textStyles.regular13.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
