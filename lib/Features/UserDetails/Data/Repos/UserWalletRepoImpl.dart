import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/TeacherWalletModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserWalletRepo.dart';

class UserWalletRepoImpl implements UserWalletRepo {
  final DataBaseService dataBaseService;

  UserWalletRepoImpl({required this.dataBaseService});

  @override
  Future<Either<Failure, void>> setTeacherWallet({
    required String userID,
    required WalletEntity walletEntity,
  }) async {
    try {
      await dataBaseService.updateData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: userID,
        ),
        data: TeacherWalletModel.fromEntity(walletEntity).toJson(),
        field: "teacherExtraData.wallet",
      );
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(message: e.message));
    } catch (e) {
      return left(
        ServerFailure(message: "حدث خطاء غير متوقع، يرجى المحاولة لاحقاً"),
      );
    }
  }
}
