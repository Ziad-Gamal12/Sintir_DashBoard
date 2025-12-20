import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class VideoNoteEntity {
  final UserEntity user;
  final DateTime dateTime;
  String note;
  VideoNoteEntity({
    required this.user,
    required this.dateTime,
    required this.note,
  });
  static VideoNoteEntity empty() => VideoNoteEntity(
    user: UserEntity.empty(),
    dateTime: DateTime.now(),
    note: 'loading',
  );
}
