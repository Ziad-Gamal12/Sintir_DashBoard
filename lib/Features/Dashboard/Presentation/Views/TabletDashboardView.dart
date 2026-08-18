import 'package:material_ui/material_ui.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class TabletDashboardView extends StatelessWidget {
  const TabletDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomDesktopDashboardLayout(currentIndex: 0));
  }
}
