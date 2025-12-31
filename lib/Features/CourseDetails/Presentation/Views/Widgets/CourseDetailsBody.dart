import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSummaryCardsGrid.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCoursDetailsSectionCard.dart';

class CourseDetailsBody extends StatelessWidget {
  const CourseDetailsBody({super.key, required this.course});
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: Provider.value(
        value: course,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: CourseDetailsHeader()),
            SliverToBoxAdapter(child: Divider(height: 48)),
            CourseDetailsSummaryCardsGrid(),
            SliverToBoxAdapter(child: Divider(height: 48)),
            SliverToBoxAdapter(child: CustomCoursDetailsSectionCard()),
          ],
        ),
      ),
    );
  }
}
