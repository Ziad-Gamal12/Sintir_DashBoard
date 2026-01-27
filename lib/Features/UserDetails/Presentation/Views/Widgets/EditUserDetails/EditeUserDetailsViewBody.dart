import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/edit_user_cubit/edit_user_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/EditUserDetails/EditUserActionButton.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/EditUserDetails/EditeUserDetailsTextFields.dart';

class EditUserDetailsViewBody extends StatefulWidget {
  const EditUserDetailsViewBody({super.key, required this.userEntity});
  final UserEntity userEntity;

  @override
  State<EditUserDetailsViewBody> createState() =>
      _EditUserDetailsViewBodyState();
}

class _EditUserDetailsViewBodyState extends State<EditUserDetailsViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditUserCubit, EditUserState>(
      listener: (context, state) {
        if (state is EditUserSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم التعديل بنجاح",
            type: SnackType.success,
          );
          Navigator.pop(context);
        } else if (state is EditUserFailure) {
          CustomSnackBar.show(
            context,
            message: state.errmessage,
            type: SnackType.error,
          );
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Improved UX
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            spacing: 24,
            children: [
              EditUserDetailsTextFields(user: widget.userEntity),
              const SizedBox(height: 8),
              EditUserActionButton(
                userEntity: widget.userEntity,
                formKey: _formKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
