import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class SubscriberAvatar extends StatelessWidget {
  final String imageUrl;
  const SubscriberAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, // Standard dashboard row height
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomCachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
