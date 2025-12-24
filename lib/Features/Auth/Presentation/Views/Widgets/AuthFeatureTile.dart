import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/InfoHighlightIconCard.dart';

class AuthFeatureTile extends StatefulWidget {
  const AuthFeatureTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;

  @override
  State<AuthFeatureTile> createState() => _AuthFeatureTileState();
}

class _AuthFeatureTileState extends State<AuthFeatureTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: 200.ms,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        transform: isHovered
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          border: Border.all(
            color: isHovered ? widget.iconColor : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            InfoHighlightIconCard(icon: widget.icon, color: widget.iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles(context).semiBold16.copyWith(
                      color: isHovered
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: AppTextStyles(
                      context,
                    ).regular13.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
