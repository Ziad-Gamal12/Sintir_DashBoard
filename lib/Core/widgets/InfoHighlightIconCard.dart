import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoHighlightIconCard extends StatelessWidget {
  const InfoHighlightIconCard({
    super.key,
    required this.icon,
    required this.color,
  });
  final FaIconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.3),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
      ),

      child: FaIcon(icon, color: color, size: 20),
    );
  }
}
