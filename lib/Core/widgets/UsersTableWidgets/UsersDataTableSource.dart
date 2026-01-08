import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/UserInfo.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/UserRole.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/UserStatus.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class UsersDataTableSource extends DataTableSource {
  final List<UserEntity> users;
  final BuildContext context;

  UsersDataTableSource(this.users, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    final textStyles = AppTextStyles(context);

    return DataRow2(
      onTap: () {},
      cells: [
        DataCell(UserInfo(user: user)),
        DataCell(UserRole(role: user.role)),
        DataCell(
          Text(
            DateFormat('yyyy-MM-dd').format(user.joinedDate),
            style: textStyles.regular11.copyWith(color: Colors.grey),
          ),
        ),
        DataCell(UserStatus(status: user.status)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
