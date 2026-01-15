import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class SubscriberAvatar extends StatelessWidget {
  final String imageUrl;
  const SubscriberAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CustomCachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
