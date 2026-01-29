// logout_dialog.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignInView.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Theme-aware colors
    final Color dialogBackgroundColor =
        theme.dialogTheme.backgroundColor ?? theme.cardColor;
    final Color primaryTextColor = theme.textTheme.bodyLarge!.color!;
    const Color confirmButtonColor = Colors.red;
    final Color confirmTextColor = theme.colorScheme.onError;
    final Color cancelButtonColor = theme.scaffoldBackgroundColor;
    final Color cancelTextColor = primaryTextColor;
    final BorderSide cancelButtonBorder = BorderSide(color: theme.dividerColor);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: dialogBackgroundColor,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
        child: Text(
          "تسجيل الخروج",
          style: AppTextStyles(context).semiBold14.copyWith(
            color: primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Custombutton(
                onPressed: () async {
                  await FirebaseAuthService().signout();
                  if (context.mounted) {
                    GoRouter.of(context).go(SignInView.routeName);
                  }
                },
                text: "تأكيد",
                color: confirmButtonColor,
                textColor: confirmTextColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Custombutton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: "تراجع",
                color: cancelButtonColor,
                textColor: cancelTextColor,
                side: cancelButtonBorder,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
