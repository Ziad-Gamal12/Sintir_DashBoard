import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CourseDataTableSource.dart';
import 'package:sintir_dashboard/constant.dart';

class ResponsiveCourseTable extends StatefulWidget {
  final List<CourseEntity> courses;
  final Function(int rowIndex)? onLoadMore;
  final bool isLoading;

  const ResponsiveCourseTable({
    super.key,
    required this.courses,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  State<ResponsiveCourseTable> createState() => _ResponsiveCourseTableState();
}

class _ResponsiveCourseTableState extends State<ResponsiveCourseTable> {
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    final dataSource = CourseDataTableSource(widget.courses, context);

    return Stack(
      alignment: Alignment.center,
      children: [
        PaginatedDataTable2(
          columnSpacing: 20,
          horizontalMargin: 20,
          minWidth: 1000,
          headingRowHeight: 50,
          dataRowHeight: 75,
          renderEmptyRowsInTheEnd: false,
          rowsPerPage: 10,
          showFirstLastButtons: true,
          // Triggered when user clicks next/back
          onPageChanged: (rowIndex) {
            if (widget.onLoadMore != null) {
              widget.onLoadMore!(rowIndex);
            }
          },
          headingTextStyle: textStyles.bold14.copyWith(color: Colors.grey),
          columns: const [
            DataColumn2(label: Text('الكورس'), size: ColumnSize.L),
            DataColumn2(label: Text('المادة'), size: ColumnSize.M),
            DataColumn2(label: Text('المعلم'), size: ColumnSize.M),
            DataColumn2(label: Text('السعر'), size: ColumnSize.S),
            DataColumn2(label: Text('عدد الطلاب'), size: ColumnSize.S),
            DataColumn2(label: Text('الحالة'), size: ColumnSize.S),
          ],
          source: dataSource,
        ),

        // --- Premium Loading Overlay ---
        if (widget.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: KMainColor,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}
