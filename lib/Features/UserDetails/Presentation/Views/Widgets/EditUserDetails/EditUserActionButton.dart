import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/edit_user_cubit/edit_user_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class EditUserActionButton extends StatelessWidget {
  const EditUserActionButton({
    super.key,
    required this.userEntity,
    required this.formKey,
  });
  final UserEntity userEntity;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EditUserCubit, EditUserState, bool>(
      selector: (state) => state is EditUserLoading,
      builder: (context, isLoading) {
        return SizedBox(
          width: double.infinity,
          child: Custom_Loading_Widget(
            isLoading: isLoading,
            child: Custombutton(
              color: KMainColor,
              textColor: Colors.white,
              text: "حفظ التعديلات",
              onPressed: isLoading
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        context.read<EditUserCubit>().editUser(
                          userEntity: userEntity,
                        );
                      }
                    },
            ),
          ),
        );
      },
    );
  }
}
