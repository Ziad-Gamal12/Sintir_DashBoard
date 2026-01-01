import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/SectionItemContent.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/SectionItemHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomContentListViewItem extends StatefulWidget {
  const CustomContentListViewItem({
    super.key,
    required this.sectionItem,
    required this.course,
  });

  final CourseSectionEntity sectionItem;
  final CourseEntity course;

  @override
  State<CustomContentListViewItem> createState() =>
      _CustomContentListViewItemState();
}

class _CustomContentListViewItemState extends State<CustomContentListViewItem> {
  bool _isExpanded = false;
  List<dynamic> sectionLessons = [];

  void _handleTap() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded && sectionLessons.isEmpty) {
      context.read<CourseSectionsCubit>().getSectionItems(
        sectionId: widget.sectionItem.id,
        courseId: widget.course.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return BlocConsumer<CourseSectionsCubit, CourseSectionsState>(
      listenWhen: (previous, current) =>
          current is GetSectionItemsSuccess &&
          current.sectionId == widget.sectionItem.id,
      listener: (context, state) {
        if (state is GetSectionItemsSuccess) {
          setState(() => sectionLessons = state.items);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is GetSectionItemsLoading &&
            state.sectionId == widget.sectionItem.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _isExpanded
                ? theme.cardColor
                : Colors.grey.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExpanded
                  ? KMainColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                      color: KMainColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionItemHeader(
                title: widget.sectionItem.title,
                isExpanded: _isExpanded,
                onTap: _handleTap,
              ),
              SectionItemContent(
                isExpanded: _isExpanded,
                isLoading: isLoading,
                sectionItem: widget.sectionItem,
                sectionLessons: sectionLessons,
                course: widget.course,
              ),
            ],
          ),
        );
      },
    );
  }
}
