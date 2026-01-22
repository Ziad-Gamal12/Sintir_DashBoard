import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserDetailRepo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/CustomUserInfoCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SectionHeader.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsDesktopLayout.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsMobileLayout.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserTransactionsSliverGrid.dart';

class UserDetailsViewBody extends StatelessWidget {
  const UserDetailsViewBody({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final bool isWideLayout = MediaQuery.sizeOf(context).width > 1100;

    return BlocProvider(
      create: (context) =>
          UserDetailsCubit(userDetailRepo: getIt<UserDetailsRepo>())
            ..callAll(userID: userId),
      child: BlocListener<UserDetailsCubit, UserDetailsState>(
        listener: (context, state) {
          if (state is DeleteUserSuccess) {
            CustomSnackBar.show(
              context,
              message: "تم حذف المستخدم بنجاح",
              type: SnackType.success,
            );
            Navigator.pop(context);
          } else if (state is DeleteUserFailure) {
            CustomSnackBar.show(
              context,
              message: state.errmessage,
              type: SnackType.error,
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppPadding.horizontal(context),
            vertical: AppPadding.vertical(context),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: CustomUserInfoCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: isWideLayout
                    ? UserDetailsDesktopLayout(userID: userId)
                    : UserDetailsMobileLayout(userID: userId),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: SectionHeader(title: "المعاملات المالية"),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 16)),
              UserTransactionsSliverGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
