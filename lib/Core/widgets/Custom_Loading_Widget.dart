// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sintir_dashboard/constant.dart';

class Custom_Loading_Widget extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const Custom_Loading_Widget({
    super.key,
    required this.isLoading,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: KMainColor,
              size: 50,
            ),
          )
        : child;
  }
}
