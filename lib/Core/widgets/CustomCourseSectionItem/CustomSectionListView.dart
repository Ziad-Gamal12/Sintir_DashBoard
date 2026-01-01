import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomFileListViewItem.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomTestListViewItem.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomVedioListViewItem.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';

class CustomSectionListView extends StatefulWidget {
  const CustomSectionListView({
    super.key,
    required this.section,
    required this.items,
    required this.course,
  });
  final CourseSectionEntity section;
  final List<dynamic> items;
  final CourseEntity course;

  @override
  State<CustomSectionListView> createState() => _CustomSectionListViewState();
}

class _CustomSectionListViewState extends State<CustomSectionListView> {
  Widget getChild(dynamic item, BuildContext context) {
    if (item is CourseVideoItemEntity) {
      return CustomVedioListViewItem(
        course: widget.course,

        item: item,
        section: widget.section,
      );
    } else if (item is CourseTestEntity) {
      return Customtestlistviewitem(
        course: widget.course,
        item: item,
        section: widget.section,
      );
    } else {
      return Customfilelistviewitem(
        section: widget.section,
        item: item,
        course: widget.course,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseSectionsCubit, CourseSectionsState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: widget.items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: getChild(widget.items[index], context),
            );
          },
        );
      },
    );
  }
}
