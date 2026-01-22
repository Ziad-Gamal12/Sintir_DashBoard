import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';

class DelelteUserActionButton extends StatelessWidget {
  const DelelteUserActionButton({super.key, required this.userID});
  final String userID;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return BlocSelector<UserDetailsCubit, UserDetailsState, bool>(
      selector: (state) {
        return state is DeleteUserLoading;
      },
      builder: (context, isLoading) {
        if (isLoading) {
          return Center(
            child: const CircularProgressIndicator(color: Colors.red),
          );
        }
        return Custombutton(
          text: "",
          color: Colors.red.withOpacity(.1),
          textColor: Colors.red,
          onPressed: () {
            AppDialogs.warning(
              context,
              "هل أنت متأكد من رغبتك في حذف هذا المستخدم؟ هذا الإجراء لا يمكن التراجع عنه.",
              onTap: () {
                context.read<UserDetailsCubit>().deleteUser(userID: userID);
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "حذف المستخدم",
                style: textStyles.regular14.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
              Icon(Icons.delete, color: Colors.red.shade700),
            ],
          ),
        );
      },
    );
  }
}
