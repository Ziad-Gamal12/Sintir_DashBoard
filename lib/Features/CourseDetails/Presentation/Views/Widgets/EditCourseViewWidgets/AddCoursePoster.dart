// ignore_for_file: must_be_immutable, file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';

class Addcourseposter extends StatelessWidget {
  const Addcourseposter({
    super.key,
    this.coursePosterImage,
    this.coursePosterUrl,
    required this.onTap,
  });

  final Uint8List? coursePosterImage;
  final String? coursePosterUrl;
  final VoidCallback onTap;

  bool get _hasImage => coursePosterImage != null || coursePosterUrl != null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: _hasImage ? _buildImageView(context) : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color placeholderColor = theme.colorScheme.onSurface.withOpacity(
      0.05,
    );
    final Color iconColor = theme.colorScheme.primary;
    final Color textColor = theme.textTheme.bodyMedium!.color!.withOpacity(0.6);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                Assets.assetsIconsAddImageIcon,
                height: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "إضافة صورة الغلاف للدورة",
              textAlign: TextAlign.center,
              style: AppTextStyles(context).bold13.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageView(BuildContext context) {
    return Hero(
      tag: "coursePosterPreview",
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (coursePosterImage != null) {
      return Image.memory(
        coursePosterImage!,
        key: ValueKey(coursePosterImage),
        fit: BoxFit.cover,
      );
    }
    return CustomCachedNetworkImage(
      imageUrl: coursePosterUrl!,
      key: ValueKey(coursePosterUrl),
      fit: BoxFit.cover,
    );
  }
}
