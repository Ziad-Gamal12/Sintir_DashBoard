import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCoursDetailsSectionCard extends StatelessWidget {
  const CustomCoursDetailsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          CustomCoursePoster(),
          SizedBox(height: 32),
          CourseDetailsDescription(),
        ],
      ),
    );
  }
}

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

class CourseDetailsDescription extends StatefulWidget {
  const CourseDetailsDescription({super.key});

  @override
  State<CourseDetailsDescription> createState() =>
      _CourseDetailsDescriptionState();
}

class _CourseDetailsDescriptionState extends State<CourseDetailsDescription> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "وصف الكورس",
              style: AppTextStyles(
                context,
              ).semiBold20.copyWith(color: theme.textTheme.bodyLarge!.color),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? "اغلاق" : "اظهار المزيد",
                style: AppTextStyles(
                  context,
                ).regular10.copyWith(color: KMainColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.read<CourseEntity>().description,
          style: AppTextStyles(context).regular10.copyWith(color: Colors.grey),
          maxLines: isExpanded ? null : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
