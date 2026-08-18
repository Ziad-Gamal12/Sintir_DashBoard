import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class DropdownmenuItem extends StatefulWidget {
  const DropdownmenuItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<DropdownmenuItem> createState() => _DropdownMenuItemState();
}

class _DropdownMenuItemState extends State<DropdownmenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;

    if (widget.isSelected) {
      backgroundColor = widget.primaryColor.withOpacity(0.08);
    } else if (isHovered) {
      backgroundColor = widget.primaryColor.withOpacity(0.05);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),

          height: 60,

          padding: const EdgeInsets.symmetric(horizontal: 14),

          color: backgroundColor,

          alignment: Alignment.centerRight,

          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: AppTextStyles(context).regular14.copyWith(
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
