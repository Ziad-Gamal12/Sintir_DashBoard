import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class TicketsManagementDesktopView extends StatelessWidget {
  const TicketsManagementDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDesktopDashboardLayout(currentIndex: 3);
  }
}
