import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Helper/ShowBottomSheet.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Support/Data/Models/SupportChatMessageModel.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/MessageActionsBottomSheetWidgets/MessageActionsBottomSheet.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportChatListMessageItem.dart';
import 'package:sintir_dashboard/constant.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class SupportChatMessagesListView extends StatefulWidget {
  const SupportChatMessagesListView({super.key, required this.ticketID});
  final String ticketID;

  @override
  State<SupportChatMessagesListView> createState() =>
      _SupportChatMessagesListViewState();
}

class _SupportChatMessagesListViewState
    extends State<SupportChatMessagesListView> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream;
  String userId = getUserData().uid;
  @override
  void initState() {
    super.initState();
    messagesStream = FirebaseFirestore.instance
        .collection(BackendEndpoints.supportTicketsCollection)
        .doc(widget.ticketID)
        .collection(BackendEndpoints.supportTicketMessagesSubCollection)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              errormessage: "حدث خطأ ما يرجى المحاولة في وقت لاحق",
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "لا يوجد رسائل",
              style: AppTextStyles(context).regular13,
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final message = SupportChatMessageModel.fromJson(data).toEntity();
            final bool isMe = message.sender.uid == userId;
            return SupportChatListMessageItem(
              onLongPress: () {
                showCustomBottomSheet(
                  child: MessageActionsBottomSheet(
                    ticketId: widget.ticketID,
                    messageEntity: message,
                  ),
                  context: context,
                );
              },
              messageEntity: message,
              isMe: isMe,
            );
          },
        );
      },
    );
  }
}
