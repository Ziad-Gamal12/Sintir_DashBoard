import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class AppErrorView extends StatelessWidget {
  final GoException? exception;
  const AppErrorView({super.key, this.exception});

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // تدرج لوني خفيف ليناسب الفخامة
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '404',
                style: styles.extrabold70.copyWith(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'عفواً، الصفحة غير موجودة',
                textAlign: TextAlign.center,
                style: styles.bold32.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يبدو أن الرابط الذي تحاول الوصول إليه غير صحيح أو تم نقله لمكان آخر.',
                textAlign: TextAlign.center,
                style: styles.regular16.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('العودة للرئيسية', style: styles.semiBold16),
                  ],
                ),
              ),
              if (exception != null) ...[
                const SizedBox(height: 40),
                ExpansionTile(
                  title: Text('تفاصيل تقنية', style: styles.regular13),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        exception.toString(),
                        style: styles.light12.copyWith(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
