import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CustomContentCreatorCircleAvartar.dart';

class CourseItemDetailsContentCreatorCard extends StatelessWidget {
  const CourseItemDetailsContentCreatorCard({
    super.key,
    required this.contentcreaterentity,
  });
  final ContentCreatorEntity contentcreaterentity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomContentCreatorCircleAvartar(
          imagepath: contentcreaterentity.profileImageUrl,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            contentcreaterentity.name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.verified, size: 12, color: Colors.blueAccent),
      ],
    );
  }
}
