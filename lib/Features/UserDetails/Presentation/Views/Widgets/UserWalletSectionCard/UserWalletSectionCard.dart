import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserWalletRepo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_wallet_cubit/user_wallet_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/UserWalletSectionCardHeader.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/WalletInfoWrapCards.dart';

import 'UserWalletSectionCardDetailForm.dart';
import 'UserWalletSectionCardDetailInfo.dart';

class UserWalletSectionCard extends StatefulWidget {
  const UserWalletSectionCard({super.key, required this.wallet});
  final WalletEntity wallet;

  @override
  State<UserWalletSectionCard> createState() => _UserWalletSectionCardState();
}

class _UserWalletSectionCardState extends State<UserWalletSectionCard> {
  bool isEditingWallet = false;
  late TextEditingController walletIdController, lastTransactionIdController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    walletIdController = TextEditingController(
      text: widget.wallet.walletId.toString(),
    );
    lastTransactionIdController = TextEditingController(
      text: widget.wallet.lastTransactionId.toString(),
    );
  }

  @override
  void dispose() {
    walletIdController.dispose();
    lastTransactionIdController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      context.read<UserWalletCubit>().setWallet(
        userID: widget.wallet.teacherId,
        updatedWallet: widget.wallet,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getUserData();

    final bool canView = PermissionsManager.can(
      Permission.viewUsers,
      role: currentUser.role,
      status: currentUser.status,
    );

    final bool canEdit = PermissionsManager.can(
      Permission.editUser,
      role: currentUser.role,
      status: currentUser.status,
    );

    if (!canView) {
      return const CustomCard(
        child: SizedBox(
          height: 200,
          child: AccessDeniedWidgetAr(featureNameAr: "المحفظة المالية"),
        ),
      );
    }

    return BlocProvider(
      create: (context) => UserWalletCubit(
        walletRepo: getIt<UserWalletRepo>(),
        initialWallet: widget.wallet,
      ),
      child: BlocConsumer<UserWalletCubit, UserWalletState>(
        listener: (context, state) {
          if (state is SetUserWalletSuccess) {
            setState(() => isEditingWallet = false);
            CustomSnackBar.show(
              context,
              message: "تم التعديل بنجاح",
              type: SnackType.success,
            );
          }
          if (state is SetUserWalletFailure) {
            CustomSnackBar.show(
              context,
              message: state.errMessage,
              type: SnackType.error,
            );
          }
        },
        builder: (context, state) {
          return CustomCard(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  UserWalletSectionCardHeader(
                    isEditing: isEditingWallet,
                    isLoading: state is SetUserWalletLoading,
                    isEditingOnChanged: (isEditing) {
                      if (!canEdit) return;
                      if (!isEditing) {
                        _handleSave(context);
                      } else {
                        setState(() => isEditingWallet = true);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  WalletInfoWrapCards(
                    wallet: widget.wallet,
                    isEditing: isEditingWallet,
                  ),
                  const Divider(height: 40, thickness: 1.2),
                  isEditingWallet && canEdit
                      ? UserWalletSectionCardDetailForm(
                          wallet: widget.wallet,
                          walletIdController: walletIdController,
                          lastTransactionIdController:
                              lastTransactionIdController,
                          onDateChanged: () => setState(() {}),
                        )
                      : UserWalletSectionCardDetailInfo(wallet: widget.wallet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
