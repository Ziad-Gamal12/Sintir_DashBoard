import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/UserModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/FilterUsersQueryEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/GetUsersResponseEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';

class UsersRepoImpl implements UsersRepo {
  final DataBaseService dataBaseService;
  UsersRepoImpl({required this.dataBaseService});

  DocumentSnapshot? getUsersLastDoc;
  @override
  Future<Either<Failure, GetUsersResponseEntity>> getUsers(
    FilterUsersQueryEntity filters, {
    required bool isPaginate,
  }) async {
    try {
      Map<String, dynamic> query = {
        "orderBy": "joinedDate",
        "limit": 10,
        "startAfter": isPaginate ? getUsersLastDoc : null,
        "searchField": "fullName",
        "searchValue": filters.keyword,
        "filters": _buildGetUsersFilters(filters),
      };

      final response = await dataBaseService.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
        ),
        query: query,
      );
      if (response.listData == null) {
        return Left(ServerFailure(message: "فشل تحميل المستخدمين"));
      }
      if (response.listData!.isEmpty) {
        return Right(
          GetUsersResponseEntity(
            users: [],
            hasMore: false,
            isPaginate: isPaginate,
          ),
        );
      }
      if (response.lastDocumentSnapshot != null &&
          response.listData!.isNotEmpty) {
        getUsersLastDoc = response.lastDocumentSnapshot;
      }
      bool hasMore = response.hasMore ?? false;
      List<UserEntity> users = response.listData!.map((e) {
        return UserModel.fromJson(e).toEntity();
      }).toList();

      return Right(
        GetUsersResponseEntity(
          users: users,
          hasMore: hasMore,
          isPaginate: isPaginate,
        ),
      );
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }

  List<Map<String, dynamic>> _buildGetUsersFilters(
    FilterUsersQueryEntity filters,
  ) {
    List<Map<String, dynamic>> filtersList = [];
    if (filters.role != null) {
      if (filters.role!.isNotEmpty) {
        filtersList.add({
          "field": "role",
          "operator": "==",
          "value": filters.role,
        });
      }
    }
    if (filters.status != null) {
      if (filters.status!.isNotEmpty) {
        filtersList.add({
          "field": "status",
          "operator": "==",
          "value": filters.status,
        });
      }
    }
    if (filters.gender != null) {
      if (filters.gender!.isNotEmpty) {
        filtersList.add({
          "field": "gender",
          "operator": "==",
          "value": filters.gender,
        });
      }
    }
    return filtersList;
  }
}
