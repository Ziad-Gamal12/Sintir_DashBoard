import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberDataTableSource.dart';
import 'package:sintir_dashboard/constant.dart';

class ResponsiveSubscribersTable extends StatefulWidget {
  final List<SubscriberEntity> subscribers;
  final Function(int rowIndex)? onLoadMore;
  final Function(SubscriberEntity subscriber) onDelete;
  final bool isLoading;

  const ResponsiveSubscribersTable({
    super.key,
    required this.subscribers,
    required this.onDelete,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  State<ResponsiveSubscribersTable> createState() =>
      _ResponsiveSubscribersTableState();
}

class _ResponsiveSubscribersTableState
    extends State<ResponsiveSubscribersTable> {
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    final dataSource = SubscriberDataTableSource(widget.subscribers, context, (
      val,
    ) {
      widget.onDelete(val);
    });
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        PaginatedDataTable2(
          columnSpacing: 24,
          horizontalMargin: 20,
          minWidth: 1100,
          headingRowHeight: 56,
          dataRowHeight: 70,
          renderEmptyRowsInTheEnd: false,
          rowsPerPage: 10,
          showFirstLastButtons: true,
          onPageChanged: (rowIndex) {
            if (widget.onLoadMore != null) {
              widget.onLoadMore!(rowIndex);
            }
          },
          headingRowColor: WidgetStateProperty.all(
            Colors.grey.withOpacity(0.05),
          ),
          headingTextStyle: textStyles.bold14.copyWith(color: Colors.grey),
          columns: const [
            DataColumn2(label: Text('الطالب'), size: ColumnSize.L),
            DataColumn2(label: Text('المستوى الدراسي'), size: ColumnSize.M),
            DataColumn2(label: Text('الجنس'), size: ColumnSize.S),
            DataColumn2(label: Text('تاريخ الانضمام'), size: ColumnSize.M),
            DataColumn2(label: Text('العنوان'), size: ColumnSize.L),
            DataColumn2(label: Text('حذف'), size: ColumnSize.S),
          ],
          source: dataSource,
        ),
        if (widget.isLoading)
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: KMainColor),
            ),
          ),
      ],
    );
  }
}
