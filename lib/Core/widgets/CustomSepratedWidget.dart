// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Customsepratedwidget extends StatelessWidget {
  const Customsepratedwidget({super.key, required this.centerTitle});
  final String centerTitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey,
            height: 1,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(centerTitle),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            color: Colors.grey,
            height: 1,
          ),
        ),
      ],
    );
  }
}
