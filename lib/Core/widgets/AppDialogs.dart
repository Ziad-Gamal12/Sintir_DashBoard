import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class AppDialogs {
  static double _getDialogWidth(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 1024) return 450;
    return width * 0.85;
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    void Function()? onTap,
    bool isConfirm = false,
  }) {
    ThemeData theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: _getDialogWidth(context),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: AppTextStyles(context).semiBold20.copyWith(
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles(context).regular14.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onTap != null) onTap();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "حسناً",
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    if (isConfirm) ...[
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "إلغاء",
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      title: "خطأ في العملية",
      message: message,
      color: Colors.redAccent,
      icon: Icons.error_outline_rounded,
    );
  }

  static void success(
    BuildContext context,
    String message, {
    void Function()? onTap,
  }) {
    _show(
      context,
      title: "تم بنجاح",
      message: message,
      color: Colors.greenAccent.shade700,
      icon: Icons.check_circle_outline_rounded,
      onTap: onTap,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    void Function()? onTap,
  }) {
    _show(
      context,
      title: "تحذير",
      message: message,
      color: Colors.orangeAccent,
      icon: Icons.warning_amber_rounded,
      onTap: onTap,
    );
  }
}
