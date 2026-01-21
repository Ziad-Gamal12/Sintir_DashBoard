import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomUserActivityCardItem extends StatelessWidget {
  const CustomUserActivityCardItem({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.icon,
    this.unit,
  });

  final String value;
  final String title;
  final Color color;
  final IconData icon;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      decoration: _buildCardDecoration(theme),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            _buildBackgroundCircle(isMobile),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCardContent(context, theme, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBox(),
        SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 12 : 0),
        Expanded(
          flex: isMobile ? 0 : 1,
          child: _buildTextContent(context, theme, isMobile),
        ),
      ],
    );
  }

  Widget _buildIconBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    final alignment = isMobile
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = isMobile ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles(context).regular13.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            "$value ${unit ?? ''}",
            key: ValueKey(value),
            textAlign: textAlign,
            style: AppTextStyles(context).bold20.copyWith(
              fontSize: isMobile ? 18 : 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundCircle(bool isMobile) {
    return Positioned(
      right: isMobile ? 0 : -30,
      left: isMobile ? 0 : null,
      bottom: isMobile ? null : 0,
      top: isMobile ? -30 : null,
      child: CircleAvatar(
        radius: isMobile ? 40 : 50,
        backgroundColor: color.withOpacity(0.05),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: theme.dividerColor.withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
