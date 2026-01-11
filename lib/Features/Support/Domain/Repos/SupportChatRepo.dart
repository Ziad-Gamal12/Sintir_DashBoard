import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';

abstract class SupportChatRepo {
  Future<Either<Failure, void>> sendMessage({
    required SupportChatMessageEntity message,
    required String ticketId,
  });

  Future<Either<Failure, void>> removeMessage({
    required String messageId,
    required String ticketId,
  });

  Future<Either<Failure, void>> updateMessageContent({
    required String newMessageContent,
    required String ticketId,
    String? iamgeUrl,
    required String messageId,
  });
  Future<Either<Failure, List<String>>> pickAndUplaodImage();
}
