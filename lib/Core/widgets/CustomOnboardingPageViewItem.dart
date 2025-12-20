// ignore_for_file: file_names, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class CustomOnboardingPageViewItem extends StatelessWidget {
  final String svgImage;

  const CustomOnboardingPageViewItem({
    super.key,
    required this.svgImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SvgPicture.asset(
        svgImage,
      ),
    );
  }
}
