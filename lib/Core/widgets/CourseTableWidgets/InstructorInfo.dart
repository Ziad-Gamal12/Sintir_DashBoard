import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class InstructorInfo extends StatelessWidget {
  const InstructorInfo({super.key, this.instructor});
  final Contentcreaterentity? instructor;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white10,
          child: ClipOval(
            child: CustomCachedNetworkImage(
              imageUrl: instructor?.profileImageUrl ?? '',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(instructor?.name ?? 'Unknown', style: textStyles.semiBold12),
      ],
    );
  }
}
