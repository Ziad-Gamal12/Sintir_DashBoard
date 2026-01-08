import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/CustomUsersTable.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/CustomFilterUsersSection.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/UsersManagmentHeader.dart';

class UsersManagementViewBody extends StatelessWidget {
  const UsersManagementViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: UsersManagmentHeader()),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(child: CustomFilterUsersSection()),
          SliverToBoxAdapter(child: Divider(height: 48)),

          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: ResponsiveUsersTable(
                  users: UserEntity.fakeUsers(),
                  isLoading: false,
                  onLoadMore: (val) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
