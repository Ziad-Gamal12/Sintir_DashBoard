import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/imagePickerResult.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_service.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Data/Models/SupportChatMessageModel.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Repos/SupportChatRepo.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class SupportChatRepoImpl implements SupportChatRepo {
  final DataBaseService dataBaseService;
  final PickerAssetsService pickerassetsservice;
  final StorageService storageService;
  SupportChatRepoImpl({
    required this.dataBaseService,
    required this.pickerassetsservice,
    required this.storageService,
  });

  @override
  Future<Either<Failure, void>> removeMessage({
    required String messageId,
    required String ticketId,
  }) async {
    try {
      await dataBaseService.deleteDoc(
        collectionKey: BackendEndpoints.supportTicketsCollection,
        docId: ticketId,
        subCollectionKey: BackendEndpoints.supportTicketMessagesSubCollection,
        subDocId: messageId,
      );
      return right(null);
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required SupportChatMessageEntity message,
    required String ticketId,
  }) async {
    try {
      Map<String, dynamic> json = SupportChatMessageModel.fromEntity(
        message,
      ).toJson();
      await dataBaseService.setData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
          docId: ticketId,
          subCollection: BackendEndpoints.supportTicketMessagesSubCollection,
          subDocId: message.id,
        ),
        data: json,
      );
      return right(null);
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateMessageContent({
    required String newMessageContent,
    required String ticketId,
    String? iamgeUrl,
    required String messageId,
  }) async {
    try {
      await dataBaseService.updateData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
          docId: ticketId,
          subCollection: BackendEndpoints.supportTicketMessagesSubCollection,
          subDocId: messageId,
        ),
        field: "message",
        data: newMessageContent,
      );
      if (iamgeUrl != null && iamgeUrl.isNotEmpty) {
        await dataBaseService.updateData(
          requirements: FireStoreRequirmentsEntity(
            collection: BackendEndpoints.supportTicketsCollection,
            docId: ticketId,
            subCollection: BackendEndpoints.supportTicketMessagesSubCollection,
            subDocId: messageId,
          ),
          field: "image",
          data: iamgeUrl,
        );
      }
      return right(null);
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> pickAndUplaodImage() async {
    try {
      ImagePickerResult? result = await pickerassetsservice.pickMultiImages();
      if (result.bytes == null) {
        return Left(ServerFailure(message: "لا يمكن التحميل"));
      }
      List<String> urls = [];
      for (Uint8List element in result.bytes!) {
        String url = await storageService.uploadFile(
          bytes: element,
          fileName: "${DateTime.now().millisecondsSinceEpoch}",
        );
        urls.add(url);
      }

      return right(urls);
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }
}
