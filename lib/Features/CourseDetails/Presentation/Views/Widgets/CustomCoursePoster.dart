import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CustomCoursePoster extends StatelessWidget {
  const CustomCoursePoster({super.key});

  @override
  Widget build(BuildContext context) {
    String? posterUrl = context.read<CourseEntity>().posterUrl;
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: posterUrl == null
            ? const Placeholder()
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomCachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
