part of 'support_chat_cubit.dart';

@immutable
sealed class SupportChatState {}

final class SupportChatInitial extends SupportChatState {}

//Send Message
final class SendMessageLoading extends SupportChatState {}

final class SendMessageSuccess extends SupportChatState {}

final class SendMessageFailure extends SupportChatState {
  final String errMessage;
  SendMessageFailure({required this.errMessage});
}

// removed message
final class RemoveMessageLoading extends SupportChatState {}

final class RemoveMessageSuccess extends SupportChatState {}

final class RemoveMessageFailure extends SupportChatState {
  final String errMessage;
  RemoveMessageFailure({required this.errMessage});
}

// update message
final class UpdateMessageContentLoading extends SupportChatState {}

final class UpdateMessageContentSuccess extends SupportChatState {}

final class UpdateMessageContentFailure extends SupportChatState {
  final String errMessage;
  UpdateMessageContentFailure({required this.errMessage});
}

// pickAndUplaod Message Image
final class PickAndUploadMessageImageLoading extends SupportChatState {}

final class PickAndUploadMessageImageSuccess extends SupportChatState {
  final String imageUrl;
  PickAndUploadMessageImageSuccess({required this.imageUrl});
}

final class PickAndUploadMessageImageFailure extends SupportChatState {
  final String errMessage;
  PickAndUploadMessageImageFailure({required this.errMessage});
}
