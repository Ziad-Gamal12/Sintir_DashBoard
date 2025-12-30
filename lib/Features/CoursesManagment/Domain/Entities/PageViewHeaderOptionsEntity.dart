import 'package:flutter/material.dart';

class PageViewHeaderOptionsEntity {
  final String title;
  final IconData iconData;
  final Color? footerBgColor;
  PageViewHeaderOptionsEntity({
    required this.title,

    this.footerBgColor,
    required this.iconData,
  });

  static List<PageViewHeaderOptionsEntity> getPageViewHeaderOptions() {
    return [
      PageViewHeaderOptionsEntity(
        title: "جميع الكورسات",
        iconData: Icons.grid_view,
        footerBgColor: Colors.blue,
      ),
      PageViewHeaderOptionsEntity(
        title: "مباشر الآن",
        iconData: Icons.play_circle_outline,
        footerBgColor: Colors.green,
      ),
      PageViewHeaderOptionsEntity(
        title: "قيد الأنتظار",
        iconData: Icons.hourglass_bottom,
        footerBgColor: Colors.orange,
      ),
      PageViewHeaderOptionsEntity(
        title: "منتهية",
        iconData: Icons.cancel_outlined,
        footerBgColor: Colors.red,
      ),
    ];
  }
}
