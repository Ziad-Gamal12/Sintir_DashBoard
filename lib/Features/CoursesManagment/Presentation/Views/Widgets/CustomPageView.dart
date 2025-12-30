import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/PageViewItems/CustomAllCoursesPageViewItem.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/PageViewItems/CustomDeclineCoursesPageViewItem.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/PageViewItems/CustomLiveCoursesPageViewItem.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/PageViewItems/CustomPendingCoursesPageViewItem.dart';

class CustomPageView extends StatelessWidget {
  const CustomPageView({super.key, required this.pageController});
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CustomAllCoursesPageViewItem(),
        CustomLiveCoursesPageViewItem(),
        CustomPendingCoursesPageViewItem(),
        CustomDeclineCoursesPageViewItem(),
      ],
    );
  }
}
