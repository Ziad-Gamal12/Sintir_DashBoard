import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/ResponsiveUserDetailsView.dart';
import 'package:sintir_dashboard/constant.dart';

class SubscriberDataTableSource extends DataTableSource {
  final List<SubscriberEntity> subscribers;
  final BuildContext context;
  final Function(SubscriberEntity user) deleteUser;
  SubscriberDataTableSource(this.subscribers, this.context, this.deleteUser);

  @override
  DataRow? getRow(int index) {
    if (index >= subscribers.length) return null;
    final user = subscribers[index];
    final textStyles = AppTextStyles(context);
    final isLoading = user.id == 'loading';

    return DataRow2(
      onTap: isLoading ? null : () => _showUserDetails(user, context),
      cells: [
        DataCell(
          Row(
            children: [
              _buildAvatar(user, isLoading),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: textStyles.bold14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(user.phone, style: textStyles.regular11),
                  ],
                ),
              ),
            ],
          ),
        ),

        DataCell(_buildEducationBadge(user.educationLevel, isLoading)),

        DataCell(Text(user.gender, style: textStyles.regular14)),

        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.joinedDate != null
                    ? DateFormat('yyyy/MM/dd ').format(user.joinedDate!)
                    : '--/--/--',
                style: textStyles.regular14,
              ),
              Text(
                user.joinedDate != null
                    ? DateFormat('hh:mm a').format(user.joinedDate!)
                    : '--/--/--',
                style: textStyles.regular11,
              ),
            ],
          ),
        ),

        DataCell(
          Text(
            user.address,
            style: textStyles.regular14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 6. Action Button
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
            onPressed: () {
              deleteUser(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(SubscriberEntity user, bool isLoading) {
    if (isLoading) {
      return const CircleAvatar(radius: 18, backgroundColor: Colors.grey);
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KMainColor.withOpacity(0.2), width: 1),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        backgroundImage: user.imageUrl != 'loading' && user.imageUrl.isNotEmpty
            ? NetworkImage(user.imageUrl)
            : null,
        child: user.imageUrl.isEmpty || user.imageUrl == 'loading'
            ? const Icon(Icons.person, size: 20, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildEducationBadge(String level, bool isLoading) {
    if (isLoading) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KMainColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level,
        style: const TextStyle(
          color: KMainColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUserDetails(SubscriberEntity user, BuildContext context) {
    GoRouter.of(
      context,
    ).push(ResponsiveUserDetailsView.routeName, extra: user.id);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => subscribers.length;
  @override
  int get selectedRowCount => 0;
}
