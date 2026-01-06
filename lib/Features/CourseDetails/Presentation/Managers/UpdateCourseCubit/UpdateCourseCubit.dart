// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';

part 'update_course_state.dart';

class UpdateCourseCubit extends Cubit<UpdateCourseCubitState> {
  UpdateCourseCubit({
    required this.coursesrepo,
    required this.pickerAssetsInterface,
  }) : super(UpdateCourseCubitInitial());

  final Coursesrepo coursesrepo;
  final PickerAssetsInterface pickerAssetsInterface;

  Uint8List? coursePosterImage;

  Future<void> update({required CourseEntity courseEntity}) async {
    emit(UpdateCourseCubitLoading());
    try {
      String? uploadedUrl;

      if (coursePosterImage != null) {
        final posterResult = await coursesrepo.uplaodFile(
          bytes: coursePosterImage!,
          fileName:
              '${DateTime.now().millisecondsSinceEpoch}_course_poster.png',
        );
        bool uploadFailed = false;
        posterResult.fold((failure) {
          emit(UpdateCourseCubitFailure(failure.message));
          uploadFailed = true;
        }, (url) => uploadedUrl = url);

        if (uploadFailed) return;
      }

      if (uploadedUrl != null) {
        courseEntity.posterUrl = uploadedUrl!;
      }

      final result = await coursesrepo.updateCourse(courseEntity: courseEntity);

      result.fold(
        (failure) => emit(UpdateCourseCubitFailure(failure.message)),
        (success) => emit(UpdateCourseCubitSuccess()),
      );
    } catch (e) {
      log(e.toString());
      emit(UpdateCourseCubitFailure("حدث خطأ ما، يرجى المحاولة مرة أخرى"));
    }
  }

  Future<void> pickCoursePosterImage() async {
    emit(UpdateCourseCubitAssetLoading());
    try {
      final result = await pickerAssetsInterface.pickMultiImages();

      if (result.bytes != null && result.bytes!.isNotEmpty) {
        coursePosterImage = result.bytes![0];
        // Emit the bytes to the UI
        emit(UpdateCourseCubitAssetPicked(file: coursePosterImage!));
      } else {
        emit(UpdateCourseCubitAssetFailure());
      }
    } catch (e) {
      emit(UpdateCourseCubitAssetFailure());
    }
  }
}
