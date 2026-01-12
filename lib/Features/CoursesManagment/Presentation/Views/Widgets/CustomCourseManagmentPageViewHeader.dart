import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/PageViewHeaderOptionsEntity.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CustomCourseManagmentPageViewHeaderItem.dart';

class CustomCourseManagmentPageViewHeader extends StatefulWidget {
  const CustomCourseManagmentPageViewHeader({
    super.key,
    required this.pageController,
  });
  final PageController pageController;
  @override
  State<CustomCourseManagmentPageViewHeader> createState() =>
      _CustomCourseManagmentPageViewHeaderState();
}

class _CustomCourseManagmentPageViewHeaderState
    extends State<CustomCourseManagmentPageViewHeader> {
  int currentIndex = 0;
  late final List<PageViewHeaderOptionsEntity> headerOptions;

  @override
  void initState() {
    super.initState();
    headerOptions = PageViewHeaderOptionsEntity.getCoursesHeaderOptions();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: headerOptions.asMap().entries.map((entry) {
          final int idx = entry.key;
          final entity = entry.value;
          final bool isSelected = currentIndex == idx;

          return GestureDetector(
                onTap: () {
                  if (currentIndex != idx) {
                    HapticFeedback.mediumImpact();
                    setState(() => currentIndex = idx);
                  }
                  widget.pageController.animateToPage(
                    idx,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Animate(
                    target: isSelected ? 1 : 0,
                    effects: [
                      ScaleEffect(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      ),
                    ],
                    child: CustomCourseManagmentPageViewHeaderItem(
                      footerCount: 12,
                      isSelected: isSelected,
                      entity: entity,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (idx * 80).ms, duration: 500.ms)
              .slideX(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
        }).toList(),
      ),
    );
  }
}
