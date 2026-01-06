// ignore_for_file: must_be_immutable

part of 'UpdateCourseCubit.dart';

@immutable
sealed class UpdateCourseCubitState {}

final class UpdateCourseCubitInitial extends UpdateCourseCubitState {}

final class UpdateCourseCubitSuccess extends UpdateCourseCubitState {}

final class UpdateCourseCubitFailure extends UpdateCourseCubitState {
  final String errmessage;

  UpdateCourseCubitFailure(this.errmessage);
}

final class UpdateCourseCubitLoading extends UpdateCourseCubitState {}

final class UpdateCourseCubitAssetPicked extends UpdateCourseCubitState {
  Uint8List? file;

  UpdateCourseCubitAssetPicked({required this.file});
}

final class UpdateCourseCubitAssetLoading extends UpdateCourseCubitState {}

final class UpdateCourseCubitAssetFailure extends UpdateCourseCubitState {}
