import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignInView.dart';
import 'package:sintir_dashboard/constant.dart';

class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({super.key, this.message});

  static const String routeName = '/unauthorized';

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: UnauthorizedContent(message: message),
          ),
        ),
      ),
    );
  }
}

class UnauthorizedContent extends StatelessWidget {
  const UnauthorizedContent({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UnauthorizedIcon(),

          const SizedBox(height: 24),

          const UnauthorizedTitle(),

          const SizedBox(height: 12),

          UnauthorizedMessage(message: message),

          const SizedBox(height: 32),

          const UnauthorizedActions(),
        ],
      ),
    );
  }
}

class UnauthorizedIcon extends StatelessWidget {
  const UnauthorizedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: KMainColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.lock_outline_rounded, size: 46, color: KMainColor),
      ),
    );
  }
}

class UnauthorizedTitle extends StatelessWidget {
  const UnauthorizedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'غير مصرح لك بالدخول',
      textAlign: TextAlign.center,
      style: AppTextStyles(context).bold24,
    );
  }
}

class UnauthorizedMessage extends StatelessWidget {
  const UnauthorizedMessage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      message ??
          'لا يمكنك الوصول إلى لوحة التحكم في الوقت الحالي.\n'
              'تأكد من أن حسابك يمتلك الصلاحيات المطلوبة.',
      textAlign: TextAlign.center,
      style: AppTextStyles(context).regular14.copyWith(
        height: 1.7,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
    );
  }
}

class UnauthorizedActions extends StatelessWidget {
  const UnauthorizedActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          context.go(SignInView.routeName);
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('العودة لتسجيل الدخول'),
      ),
    );
  }
}
