import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/FetchTransactionsResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Models/Transactions/TransactionModel.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseTransactionsRepo.dart';

class CourseTransactionsRepoImpl implements CourseTransactionsRepo {
  final DataBaseService databaseService;
  CourseTransactionsRepoImpl({required this.databaseService});

  DocumentSnapshot? fetchTransactionslastDocument;
  @override
  Future<Either<Failure, FetchTransactionsResponseEntity>>
  fetchCourseTransactions({
    required String courseId,
    required bool isPaginate,
  }) async {
    try {
      Map<String, dynamic> fetchTransactionsQuery = {
        "startAfter": isPaginate ? fetchTransactionslastDocument : null,
        "limit": 10,
        "orderBy": "created_at",
      };
      final response = await databaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.coursesCollection,
          docId: courseId,
          subCollection: BackendEndpoints.transactionsSubCollection,
        ),
        query: fetchTransactionsQuery,
      );
      if (response.listData == null) {
        return Left(ServerFailure(message: "لا توجد بيانات"));
      }

      if (response.listData!.isNotEmpty) {
        fetchTransactionslastDocument = response.lastDocumentSnapshot;
      }
      List<TransactionEntity> transactionEntity = response.listData!
          .map((e) => TransactionModel.fromJson(e).toEntity())
          .toList();
      bool hasMore = response.hasMore ?? false;
      return Right(
        FetchTransactionsResponseEntity(
          transactions: transactionEntity,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: "حدث خطأ غير متوقع"));
    }
  }
}
