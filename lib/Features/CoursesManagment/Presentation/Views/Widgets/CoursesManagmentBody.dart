import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentHeader.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CustomCourseManagmentPageViewHeader.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CustomFilterCoursesSection.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CustomPageView.dart';

class CoursesManagmentBody extends StatefulWidget {
  const CoursesManagmentBody({super.key});

  @override
  State<CoursesManagmentBody> createState() => _CoursesManagmentBodyState();
}

class _CoursesManagmentBodyState extends State<CoursesManagmentBody> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: CoursesManagmentHeader()),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(
            child: CustomCourseManagmentPageViewHeader(
              pageController: _pageController,
            ),
          ),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(child: CustomFilterCoursesSection()),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPageView(pageController: _pageController),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
