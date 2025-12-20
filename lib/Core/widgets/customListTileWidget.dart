// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:svg_flutter/svg_flutter.dart';

class Customlisttilewidget extends StatelessWidget {
  Customlisttilewidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.image,
    this.trailing,
  });
  final String title, image;
  final String? subtitle;
  Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final subtitleColor = theme.brightness == Brightness.dark
        ? Colors.grey[400]
        : const Color(0xffAAAAAA);

    return ListTile(
      minLeadingWidth: 24,
      titleAlignment: ListTileTitleAlignment.center,
      horizontalTitleGap: 10,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: AppTextStyles(context).semiBold16.copyWith(color: titleColor),
      ),
      leading: SizedBox(
        width: 40,
        child: Align(
          alignment: Alignment.centerRight,
          child: SvgPicture.asset(
            image,
            color: titleColor,
            fit: BoxFit.fill,
            height: 30,
            width: 30,
          ),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles(
                context,
              ).regular13.copyWith(color: subtitleColor),
            )
          : null,
      trailing: trailing,
    );
  }
}
