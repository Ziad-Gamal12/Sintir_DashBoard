import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';

class AdaptiveActionButton extends StatelessWidget {
  const AdaptiveActionButton({
    super.key,
    required this.isMobile,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  final bool isMobile;
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobileButton() : _buildDesktopButton();
  }

  Widget _buildMobileButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: textColor,
                strokeWidth: 2,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: textColor, size: 20),
              tooltip: text,
            ),
    );
  }

  Widget _buildDesktopButton() {
    return Custom_Loading_Widget(
      isLoading: isLoading,
      child: Custombutton(
        text: text,
        color: color,
        textColor: textColor,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
