import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Themes/theme_cubit.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomToggleThemeIconButton.dart';

class CustomToggleThemeWidget extends StatelessWidget {
  const CustomToggleThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.read<ThemeCubit>().toggleTheme();
      },
      child: Row(
        children: [
          CustomToggleThemeIconButton(),
          SizedBox(width: 12),
          Text(
            'تبديل المظهر',
            style: AppTextStyles(
              context,
            ).regular14.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}
