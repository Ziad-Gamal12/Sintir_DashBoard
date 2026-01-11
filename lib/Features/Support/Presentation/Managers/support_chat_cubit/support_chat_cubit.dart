import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportChatRepo.dart';

part 'support_chat_state.dart';

class SupportChatCubit extends Cubit<SupportChatState> {
  SupportChatCubit({required this.supportChatRepo})
    : super(SupportChatInitial());
  final SupportChatRepo supportChatRepo;

  Future<void> sendMessage({
    required SupportChatMessageEntity message,
    required String ticketId,
  }) async {
    emit(SendMessageLoading());
    final response = await supportChatRepo.sendMessage(
      message: message,
      ticketId: ticketId,
    );
    response.fold(
      (failure) => emit(SendMessageFailure(errMessage: failure.message)),
      (response) => emit(SendMessageSuccess()),
    );
  }

  Future<void> removeMessage({
    required String messageId,
    required String ticketId,
  }) async {
    emit(RemoveMessageLoading());
    final response = await supportChatRepo.removeMessage(
      messageId: messageId,
      ticketId: ticketId,
    );
    response.fold(
      (failure) => emit(RemoveMessageFailure(errMessage: failure.message)),
      (response) => emit(RemoveMessageSuccess()),
    );
  }

  Future<void> updateMessageContent({
    required String newMessageContent,
    String? imageUrl,
    required String ticketId,
    required String messageId,
  }) async {
    emit(UpdateMessageContentLoading());
    final response = await supportChatRepo.updateMessageContent(
      newMessageContent: newMessageContent,
      iamgeUrl: imageUrl,
      ticketId: ticketId,
      messageId: messageId,
    );
    response.fold(
      (failure) =>
          emit(UpdateMessageContentFailure(errMessage: failure.message)),
      (response) => emit(UpdateMessageContentSuccess()),
    );
  }

  Future<void> pickAndUplaodImage() async {
    emit(PickAndUploadMessageImageLoading());
    final response = await supportChatRepo.pickAndUplaodImage();
    response.fold(
      (failure) =>
          emit(PickAndUploadMessageImageFailure(errMessage: failure.message)),
      (url) => emit(PickAndUploadMessageImageSuccess(imageUrl: url[0])),
    );
  }
}
