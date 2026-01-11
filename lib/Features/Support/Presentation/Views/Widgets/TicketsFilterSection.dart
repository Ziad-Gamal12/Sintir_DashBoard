import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/FilterTicketsContants.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/CustomFilterTicketsStatusItem.dart';

class TicketsFilterSection extends StatefulWidget {
  const TicketsFilterSection({
    super.key,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  State<TicketsFilterSection> createState() => _TicketsFilterSectionState();
}

class _TicketsFilterSectionState extends State<TicketsFilterSection> {
  late TextEditingController controller;
  int selectedStatus = 0;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 350,
              child: CustomSearchTextField(
                controller: controller,
                onChanged: widget.onSearchChanged,
              ),
            ),
            SizedBox(width: 24),
            Row(
              children: FilterTicketsContants.getStatusFilters()
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final filterOption = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedStatus = index;
                          });
                          widget.onStatusChanged(filterOption.valueEn);
                        },
                        child: CustomFilterTicketsStatusItem(
                          isSelected: selectedStatus == index,
                          label: filterOption.labelAr,
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
