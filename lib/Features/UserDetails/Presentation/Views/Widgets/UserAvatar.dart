import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/constant.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  const UserAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KMainColor.withOpacity(0.2), width: 2),
      ),
      child: ClipOval(
        child: CustomCachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
