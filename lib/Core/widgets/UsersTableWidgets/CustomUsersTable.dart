import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/UsersDataTableSource.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/constant.dart';

class ResponsiveUsersTable extends StatefulWidget {
  final List<UserEntity> users;
  final Function(int rowIndex)? onLoadMore;
  final bool isLoading;

  const ResponsiveUsersTable({
    super.key,
    required this.users,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  State<ResponsiveUsersTable> createState() => _ResponsiveUsersTableState();
}

class _ResponsiveUsersTableState extends State<ResponsiveUsersTable> {
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    final dataSource = UsersDataTableSource(widget.users, context);
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
          onPageChanged: (rowIndex) {
            if (widget.onLoadMore != null) {
              widget.onLoadMore!(rowIndex);
            }
          },
          headingTextStyle: textStyles.bold14.copyWith(color: Colors.grey),
          columns: const [
            DataColumn2(label: Text('المستخدم'), size: ColumnSize.L),
            DataColumn2(label: Text('الدور'), size: ColumnSize.M),
            DataColumn2(label: Text('تاريخ التسجيل'), size: ColumnSize.M),
            DataColumn2(label: Text('الحالة'), size: ColumnSize.S),
          ],
          source: dataSource,
        ),

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
