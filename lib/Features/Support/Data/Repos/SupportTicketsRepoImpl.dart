import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Features/Support/Data/Models/SupportTicketModel.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/FilterTicketsQueryEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/GetSupportTicketsResponseEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';
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
  Future<Either<Failure, GetSupportTicketsResponseEntity>> getSupportTickets(
    FilterTicketsQueryEntity? filterTicketsQueryEntity, {
    required bool isPaginate,
  }) async {
    try {
      List<Map<String, dynamic>> filters = [];
      if (filterTicketsQueryEntity != null) {
        filters = buildFilterTicketsQueryEntity(filterTicketsQueryEntity);
      }
      Map<String, dynamic> query = {
        "orderBy": "createdAt",
        "limit": 10,
        "startAfter": isPaginate ? getUserSupportTicketsLastDoc : null,
        "filters": filters,
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

  List<Map<String, dynamic>> buildFilterTicketsQueryEntity(
    FilterTicketsQueryEntity filterTicketsQueryEntity,
  ) {
    List<Map<String, dynamic>> filters = [];
    if (filterTicketsQueryEntity.id != null) {
      if (filterTicketsQueryEntity.id!.isNotEmpty) {
        filters.add({
          "field": "id",
          "operator": "==",
          "value": filterTicketsQueryEntity.id,
        });
      }
    } else if (filterTicketsQueryEntity.status != null) {
      if (filterTicketsQueryEntity.status!.isNotEmpty) {
        filters.add({
          "field": "status",
          "operator": "==",
          "value": filterTicketsQueryEntity.status,
        });
      }
    } else if (filterTicketsQueryEntity.category != null) {
      if (filterTicketsQueryEntity.category!.isNotEmpty) {
        filters.add({
          "field": "category",
          "operator": "==",
          "value": filterTicketsQueryEntity.category,
        });
      }
    } else if (filterTicketsQueryEntity.userId != null) {
      if (filterTicketsQueryEntity.userId!.isNotEmpty) {
        filters.add({
          "field": "userId",
          "operator": "==",
          "value": filterTicketsQueryEntity.userId,
        });
      }
    }
    return filters;
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
