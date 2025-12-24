import 'package:flutter/material.dart';

class CustomGenderColoredCard extends StatelessWidget {
  const CustomGenderColoredCard({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 8, backgroundColor: color);
  }
}
