import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Data/Models/SupportTicketModel.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/GetSupportTicketsResponseEntity.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Repos/SupportTicketsRepo.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class SupportTicketsRepoImpl implements SupportTicketsRepo {
  final DataBaseService dataBaseService;

  SupportTicketsRepoImpl({required this.dataBaseService});

  @override
  Future<Either<Failure, void>> deleteSupportTicket({
    required String ticketId,
  }) async {
    try {
      await dataBaseService.deleteDoc(
        collectionKey: BackendEndpoints.supportTicketsCollection,
        docId: ticketId,
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

  DocumentSnapshot? getUserSupportTicketsLastDoc;

  @override
  Future<Either<Failure, GetSupportTicketsResponseEntity>>
  getUserSupportTickets({
    required String userId,
    required bool isPaginate,
  }) async {
    try {
      Map<String, dynamic> query = {
        "orderBy": "createdAt",
        "limit": 10,
        "startAfter": isPaginate ? getUserSupportTicketsLastDoc : null,
        "filters": <Map<String, dynamic>>[
          {"field": "sender.uid", "operator": "==", "value": userId},
        ],
      };

      final response = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
        ),
        query: query,
      );
      if (response.listData == null) {
        return left(ServerFailure(message: "لا يوجد تذاكر"));
      }
      if (response.listData!.isEmpty) {
        return right(
          GetSupportTicketsResponseEntity(
            isPaginate: isPaginate,
            supportTickets: [],
            hasMore: false,
          ),
        );
      }
      if (response.lastDocumentSnapshot != null) {
        getUserSupportTicketsLastDoc = response.lastDocumentSnapshot;
      }
      List<SupportTicketEntity> supportTickets = response.listData!
          .map((e) => SupportTicketModel.fromJson(e).toEntity())
          .toList();

      return right(
        GetSupportTicketsResponseEntity(
          isPaginate: isPaginate,
          supportTickets: supportTickets,
          hasMore: response.hasMore ?? false,
        ),
      );
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطأ ما يرجى المحاولة فى وقت أخر"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendSupportTicket({
    required SupportTicketEntity supportTicket,
  }) async {
    try {
      Map<String, dynamic> json = SupportTicketModel.fromEntity(
        supportTicket,
      ).toJson();
      await dataBaseService.setData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
          docId: supportTicket.id,
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
  Future<Either<Failure, void>> updateSupportTicketStatus({
    required String supportTicketId,
    required String status,
  }) async {
    try {
      await dataBaseService.updateData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.supportTicketsCollection,
          docId: supportTicketId,
        ),
        field: "status",
        data: status,
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
}
