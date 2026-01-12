import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/CustomUsersTable.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/CustomFilterUsersSection.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/UsersManagmentHeader.dart';

class UsersManagementViewBodyHandler extends StatefulWidget {
  const UsersManagementViewBodyHandler({super.key});

  @override
  State<UsersManagementViewBodyHandler> createState() =>
      _UsersManagementViewBodyHandlerState();
}

class _UsersManagementViewBodyHandlerState
    extends State<UsersManagementViewBodyHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<UsersManagementCubit>().getUsers(isPaginate: false);
    });
  }

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
          SliverToBoxAdapter(
            child: CustomFilterUsersSection(
              onFilter: (val) {
                context.read<UsersManagementCubit>().filterUsers(val);
              },
            ),
          ),
          SliverToBoxAdapter(child: Divider(height: 48)),
          BlocBuilder<UsersManagementCubit, UsersManagementState>(
            builder: (context, state) {
              final cubit = context.read<UsersManagementCubit>();
              if (state is GetUsersManagementFailure && cubit.users.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: CustomErrorWidget(errormessage: state.errMessage),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ResponsiveUsersTable(
                      users: cubit.users,
                      isLoading: state is GetUsersManagementLoading,
                      onLoadMore: (val) {
                        if (cubit.hasMore &&
                            state is! GetUsersManagementLoading) {
                          cubit.getUsers(isPaginate: true);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
