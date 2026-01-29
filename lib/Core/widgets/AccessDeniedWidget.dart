import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class AccessDeniedWidgetAr extends StatelessWidget {
  final String featureNameAr;
  final VoidCallback? onActionPressed;

  const AccessDeniedWidgetAr({
    super.key,
    required this.featureNameAr,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(isDarkMode ? 0.1 : 0.05),
                ),
                child: Center(
                  child: Icon(
                    Icons.gpp_maybe_rounded,
                    size: 70,
                    color: isDarkMode
                        ? const Color(0xFFFF5252)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Title in Arabic
              Text(
                'وصول مقيد',
                style: styles.bold24.copyWith(
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1C1E),
                  height: 1.4, // Improved line height for Arabic
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'عذراً، صلاحيات حسابك الحالية لا تسمح لك بالوصول إلى $featureNameAr. يرجى التواصل مع مدير النظام للمساعدة.',
                textAlign: TextAlign.center,
                style: styles.regular14.copyWith(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF5A5F67),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),

              // Premium Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF32323D)
                        : const Color(0xFF1E1E26),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDarkMode
                          ? const BorderSide(color: Colors.white10)
                          : BorderSide.none,
                    ),
                    elevation: 0,
                  ),
                  child: Text('العودة للخلف', style: styles.semiBold16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
