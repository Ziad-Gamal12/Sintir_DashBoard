import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomTrashIcon extends StatelessWidget {
  const CustomTrashIcon({
    super.key,
    required this.onpressed,
    required this.isLoading,
  });
  final VoidCallback onpressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    }
    return IconButton(
        onPressed: onpressed,
        icon: const Icon(
          FontAwesomeIcons.trash,
          color: Colors.red,
        ));
  }
}
