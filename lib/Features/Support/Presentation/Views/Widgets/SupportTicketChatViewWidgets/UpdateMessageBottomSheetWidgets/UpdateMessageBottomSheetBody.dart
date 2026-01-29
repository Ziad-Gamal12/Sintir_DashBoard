import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';
import 'package:sintir_dashboard/Core/widgets/Custom_Loading_Widget.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomPickAndUploadMessageImage.dart';

class UpdateMessageBottomSheetBody extends StatefulWidget {
  final String ticketId;
  final SupportChatMessageEntity messageEntity;

  const UpdateMessageBottomSheetBody({
    super.key,
    required this.ticketId,
    required this.messageEntity,
  });

  @override
  State<UpdateMessageBottomSheetBody> createState() =>
      _UpdateMessageBottomSheetBodyState();
}

class _UpdateMessageBottomSheetBodyState
    extends State<UpdateMessageBottomSheetBody> {
  late final TextEditingController messageController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController(
      text: widget.messageEntity.message,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    final bool canEditMessage = PermissionsManager.can(
      Permission.replyTickets,
      role: user.role,
      status: user.status,
    );

    if (!canEditMessage) {
      return const SizedBox(
        height: 300,
        child: AccessDeniedWidgetAr(featureNameAr: "تعديل الرسالة"),
      );
    }

    return BlocListener<SupportChatCubit, SupportChatState>(
      listener: (context, state) {
        if (state is UpdateMessageContentSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم تحديث الرسالة بنجاح",
            type: SnackType.success,
          );
          context.pop();
        } else if (state is UpdateMessageContentFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is PickAndUploadMessageImageSuccess) {
          widget.messageEntity.image = state.imageUrl;
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  obscureText: false,
                  hintText: "ادخل رسالة",
                  controller: messageController,
                  textInputType: TextInputType.multiline,
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "ادخل رسالة"
                      : null,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: CustomPickAndUploadMessageImage(
                    supportChatMessageImage: widget.messageEntity.image ?? "",
                  ),
                ),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SupportChatCubit, SupportChatState>(
      builder: (context, state) {
        final isLoading = state is UpdateMessageContentLoading;
        return Custom_Loading_Widget(
          isLoading: isLoading,
          child: SizedBox(
            width: double.infinity,
            child: Custombutton(
              text: "تحديث الرسالة",
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  context.read<SupportChatCubit>().updateMessageContent(
                    ticketId: widget.ticketId,
                    messageId: widget.messageEntity.id,
                    newMessageContent: messageController.text.trim(),
                    imageUrl: widget.messageEntity.image,
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
