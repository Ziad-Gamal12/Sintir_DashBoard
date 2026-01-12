import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class GetUsersResponseEntity {
  final List<UserEntity> users;
  final bool hasMore, isPaginate;

  GetUsersResponseEntity({
    required this.users,
    required this.hasMore,
    required this.isPaginate,
  });
}
