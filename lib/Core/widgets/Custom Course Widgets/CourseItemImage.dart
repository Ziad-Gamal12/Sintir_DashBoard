import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CourseItemImage extends StatelessWidget {
  const CourseItemImage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomCachedNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );
  }
}
