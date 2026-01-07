import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class CreatorAvatar extends StatelessWidget {
  final String imageUrl;
  const CreatorAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3), // The Ring thickness
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff7F5AFF), Color(0xff5F9BFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7F5AFF).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 56,
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CustomCachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
