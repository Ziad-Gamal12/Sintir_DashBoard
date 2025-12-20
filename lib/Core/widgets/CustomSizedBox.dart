// ignore_for_file: must_be_immutable, file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class Customsizedbox extends StatelessWidget {
  const Customsizedbox({
    required this.width,
    required this.height,
  });
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
    );
  }
}
