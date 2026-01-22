// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CustomContentCreatorCircleAvartar extends StatelessWidget {
  const CustomContentCreatorCircleAvartar({super.key, required this.imagepath});
  final String imagepath;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: CustomCachedNetworkImage(imageUrl: imagepath),
        ),
      ),
    );
  }
}
