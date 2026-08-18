import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomDropDownButton/DropdownMenuItem.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';

class CustomAnimatedDropDownButton extends StatefulWidget {
  const CustomAnimatedDropDownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  State<CustomAnimatedDropDownButton> createState() =>
      _CustomAnimatedDropDownButtonState();
}

class _CustomAnimatedDropDownButtonState
    extends State<CustomAnimatedDropDownButton>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();

  final TextEditingController textEditingController = TextEditingController();

  OverlayEntry? _overlayEntry;

  String? selectedValue;

  bool _isOpen = false;
  bool _isHovered = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    textEditingController.addListener(_refreshOverlay);
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_overlayEntry != null) return;

    setState(() {
      _isOpen = true;
    });

    final overlay = Overlay.of(context, rootOverlay: true);

    _overlayEntry = OverlayEntry(builder: _buildOverlay);

    overlay.insert(_overlayEntry!);

    _animationController.forward(from: 0);
  }

  void _closeDropdown() {
    if (_overlayEntry == null) return;

    _overlayEntry!.remove();
    _overlayEntry = null;

    _animationController.reset();

    textEditingController.clear();

    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _selectItem(String value) {
    setState(() {
      selectedValue = value;
    });

    widget.onChanged(value);

    _closeDropdown();
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.grey.shade300;

    final dropdownBg = theme.colorScheme.surface;

    final searchValue = textEditingController.text.trim().toLowerCase();

    final filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(searchValue))
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 8),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 250,
                  child: Material(
                    color: dropdownBg,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),

                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              child: CustomSearchTextField(
                                controller: textEditingController,
                              ),
                            ),
                            if (filteredItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'لا توجد نتائج',
                                  style: AppTextStyles(context).regular14
                                      .copyWith(
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                ),
                              )
                            else
                              Flexible(
                                fit: FlexFit.loose,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  shrinkWrap: true,
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    return DropdownmenuItem(
                                      title: item,
                                      isSelected: item == selectedValue,
                                      primaryColor: primaryColor,
                                      isDark: isDark,
                                      onTap: () {
                                        _selectItem(item);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;

    final normalBorderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.grey.shade300;

    final borderColor = _isOpen || _isHovered
        ? primaryColor.withOpacity(0.6)
        : normalBorderColor;

    return CompositedTransformTarget(
      link: _layerLink,

      child: MouseRegion(
        cursor: SystemMouseCursors.click,

        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },

        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },

        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleDropdown,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              color: Colors.transparent,
            ),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? widget.hintText ?? 'اختر...',

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: AppTextStyles(context).regular13.copyWith(
                      color: selectedValue == null
                          ? isDark
                                ? Colors.white60
                                : Colors.black54
                          : isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    textEditingController.removeListener(_refreshOverlay);

    textEditingController.dispose();
    _animationController.dispose();

    super.dispose();
  }
}
