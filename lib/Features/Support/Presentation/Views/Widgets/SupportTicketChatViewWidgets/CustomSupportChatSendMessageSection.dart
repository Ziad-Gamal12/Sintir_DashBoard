import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportSenderEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomPickAndUploadMessageImage.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomSupportChatSendMessageTextField.dart';
import 'package:uuid/uuid.dart';

class CustomSupportChatSendMessageSection extends StatefulWidget {
  const CustomSupportChatSendMessageSection({
    super.key,
    required this.ticketId,
  });
  final String ticketId;
  @override
  State<CustomSupportChatSendMessageSection> createState() =>
      _CustomSupportChatSendMessageSectionState();
}

class _CustomSupportChatSendMessageSectionState
    extends State<CustomSupportChatSendMessageSection> {
  late TextEditingController controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SupportChatMessageEntity? message;
  UserEntity userEntity = getUserData();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Check permission to reply
    final bool canReply = PermissionsManager.can(
      Permission.replyTickets,
      role: userEntity.role,
      status: userEntity.status,
    );

    // If no permission, hide the entire input section
    if (!canReply) {
      return const SizedBox.shrink();
    }

    return BlocListener<SupportChatCubit, SupportChatState>(
      listener: (context, state) {
        if (state is PickAndUploadMessageImageFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is PickAndUploadMessageImageSuccess) {
          message?.image = state.imageUrl;
        } else if (state is SendMessageSuccess) {
          controller.clear();
        } else if (state is SendMessageFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        }
      },
      child: Form(
        key: formKey,
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomSupportChatSendMessageTextField(
                    formKey: formKey,
                    controller: controller,
                    ticketId: widget.ticketId,
                    onSend: () {
                      if (formKey.currentState!.validate()) {
                        message = SupportChatMessageEntity(
                          id: const Uuid().v4(),
                          createdAt: DateTime.now(),
                          message: controller.text,
                          image: message?.image,
                          sender: SupportSenderEntity(
                            uid: userEntity.uid,
                            name: userEntity.fullName.toUpperCase(),
                            email: userEntity.email,
                            role: userEntity.role,
                            photoUrl: userEntity.profilePicurl,
                            phone: userEntity.phoneNumber,
                          ),
                        );

                        context.read<SupportChatCubit>().sendMessage(
                          message: message!,
                          ticketId: widget.ticketId,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CustomPickAndUploadMessageImage(
                    supportChatMessageImage: message?.image ?? "",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
