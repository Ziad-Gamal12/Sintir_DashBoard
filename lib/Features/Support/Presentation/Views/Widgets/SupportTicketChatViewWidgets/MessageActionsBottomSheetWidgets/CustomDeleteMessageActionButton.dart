import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';

class CustomDeleteMessageActionButton extends StatefulWidget {
  const CustomDeleteMessageActionButton({
    super.key,
    required this.ticketId,
    required this.messageEntity,
  });
  final String ticketId;
  final SupportChatMessageEntity messageEntity;
  @override
  State<CustomDeleteMessageActionButton> createState() =>
      _CustomDeleteMessageActionButtonState();
}

class _CustomDeleteMessageActionButtonState
    extends State<CustomDeleteMessageActionButton> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportChatCubit, SupportChatState>(
      buildWhen: (previous, current) {
        return current is RemoveMessageFailure ||
            current is RemoveMessageSuccess ||
            current is RemoveMessageLoading;
      },
      listener: (context, state) {
        if (state is RemoveMessageFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is RemoveMessageSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم حذف الرسالة بنجاح",
            type: SnackType.success,
          );
          GoRouter.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is RemoveMessageLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }
        return SizedBox(
          width: double.infinity,
          child: Custombutton(
            text: "حذف الرسالة",
            color: Colors.red.shade700,
            textColor: Colors.white,
            onPressed: () {
              context.read<SupportChatCubit>().removeMessage(
                messageId: widget.messageEntity.id,
                ticketId: widget.ticketId,
              );
            },
          ),
        );
      },
    );
  }
}
