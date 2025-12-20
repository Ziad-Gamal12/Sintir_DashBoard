import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CustomCourseHorizontalItemPosterUrl extends StatelessWidget {
  const CustomCourseHorizontalItemPosterUrl({super.key, required this.poster});

  final String poster;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 1 / 1.45,
        child: CustomCachedNetworkImage(imageUrl: poster, fit: BoxFit.cover),
      ),
    );
  }
}
