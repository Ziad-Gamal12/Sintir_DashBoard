import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/add_subscribers_to_course_cubit/add_subscribers_to_course_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/DialogActions.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/DialogHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/SelectedUsersWrap.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/AddSubscribersToCourseDialog/UserListSection.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/FilterUsersQueryEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';

class UserSelectionDialog extends StatefulWidget {
  final CourseEntity courseEntity;
  const UserSelectionDialog({super.key, required this.courseEntity});

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  final List<UserEntity> _selectedUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debouncer;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<UsersManagementCubit>();
    cubit.getUsers(isPaginate: false);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = context.read<UsersManagementCubit>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (cubit.state is! GetUsersManagementLoading && cubit.hasMore) {
        cubit.getUsers(isPaginate: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      context.read<UsersManagementCubit>().filterUsers(
        FilterUsersQueryEntity(keyword: query),
      );
    });
  }

  void _toggleUser(UserEntity user, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedUsers.add(user);
      } else {
        _selectedUsers.removeWhere((u) => u.uid == user.uid);
      }
    });
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<
      AddSubscribersToCourseCubit,
      AddSubscribersToCourseState
    >(
      listener: (context, state) {
        if (state is AddSubscribersToCourseFailure) {
          CustomSnackBar.show(
            context,
            message: state.errmessage,
            type: SnackType.error,
          );
        } else if (state is AddSubscribersToCourseSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم اضافة المستخدمين بنجاح",
            type: SnackType.success,
          );
          GoRouter.of(context).pop();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        color: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const DialogHeader(),
            const SizedBox(height: 20),
            CustomSearchTextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 10),
            SelectedUsersWrap(
              selectedUsers: _selectedUsers,
              onDelete: (user) => _toggleUser(user, false),
            ),
            const Divider(),
            Expanded(
              child: UserListSection(
                scrollController: _scrollController,
                selectedUsers: _selectedUsers,
                onUserToggled: _toggleUser,
              ),
            ),
            const Divider(),
            DialogActions(
              selectedCount: _selectedUsers.length,
              onConfirm: () {
                context.read<AddSubscribersToCourseCubit>().addSubscribers(
                  usersEntity: _selectedUsers,
                  course: widget.courseEntity,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
