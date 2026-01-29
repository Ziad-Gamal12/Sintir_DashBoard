// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSectionsResonseEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSectionsRepos/CourseSectionsRepo.dart';

part 'CourseSectionsState.dart';

class CourseSectionsCubit extends Cubit<CourseSectionsState> {
  CourseSectionsCubit(this._courseSectionsRepo)
    : super(AddCourseSectionInitial());

  final CourseSectionsRepo _courseSectionsRepo;
  List<CourseSectionEntity> courseSections = [];
  bool hasMore = true;

  void _emitFailure(Failure failure) {
    // If you have different failure states use logic to emit appropriate one.
    // For simplicity we emit a general failure state when applicable.
    emit(AddCourseSectionFailure(errMessage: failure.message));
  }

  // -----------------------
  // Add a whole section then (optionally) add item(s) to it
  // -----------------------
  Future<void> addCourseSection({
    required CourseSectionEntity section,
    required String courseId,
    required dynamic sectionItem,
  }) async {
    emit(AddCourseSectionLoading());

    final Either<Failure, void> addSectionResult = await _courseSectionsRepo
        .addCourseSection(section: section, courseId: courseId);

    addSectionResult.fold(
      (failure) {
        _emitFailure(failure);
      },
      (r) async {
        final Either<Failure, void> addItemResult = await _courseSectionsRepo
            .addSectionItem(
              courseId: courseId,
              sectionId: section.id,
              sectionItem: sectionItem,
            );

        addItemResult.fold(
          (failure) => _emitFailure(failure),
          (_) => emit(AddCourseSectionSuccess()),
        );
      },
    );
  }

  // -----------------------
  // Add single section item
  // -----------------------
  Future<void> addSectionItem({
    required String courseId,
    required String sectionId,
    required dynamic sectionItem,
  }) async {
    emit(AddCourseSectionItemLoading());

    final Either<Failure, void> result = await _courseSectionsRepo
        .addSectionItem(
          sectionItem: sectionItem,
          courseId: courseId,
          sectionId: sectionId,
        );

    result.fold(
      (failure) =>
          emit(AddCourseSectionItemFailure(errMessage: failure.message)),
      (_) => emit(AddCourseSectionItemSuccess()),
    );
  }

  // -----------------------
  // Get course sections (with pagination flag)
  // -----------------------
  Future<void> getCourseSections({
    required String courseId,
    required bool isPaginate,
  }) async {
    emit(GetCourseSectionsLoading(isPaginate: isPaginate));

    final Either<Failure, GetCourseSectionsResonseEntity> result =
        await _courseSectionsRepo.getCourseSections(
          courseId: courseId,
          isPaginate: isPaginate,
        );

    result.fold(
      (failure) => emit(GetCourseSectionsFailure(errMessage: failure.message)),
      (sections) {
        handleFetchedSectionsSuccessState(sections);
        emit(GetCourseSectionsSuccess(response: sections));
      },
    );
  }

  void handleFetchedSectionsSuccessState(
    GetCourseSectionsResonseEntity response,
  ) {
    if (response.isPaginate) {
      courseSections.addAll(response.sections);
    } else {
      courseSections = response.sections;
    }
    hasMore = response.hasMore;
  }

  // -----------------------
  // Get items for a specific section
  // -----------------------
  Future<void> getSectionItems({
    required String sectionId,
    required String courseId,
  }) async {
    emit(GetSectionItemsLoading(sectionId: sectionId));

    // Prefer typed list where possible
    final Either<Failure, List<dynamic>> result = await _courseSectionsRepo
        .getSectionsItems(courseId: courseId, sectionId: sectionId);

    result.fold(
      (failure) => emit(GetSectionItemsFailure(errMessage: failure.message)),
      (items) =>
          emit(GetSectionItemsSuccess(items: items, sectionId: sectionId)),
    );
  }

  // -----------------------
  // Delete a specific section item
  // -----------------------
  Future<void> deleteSectionItem({
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  }) async {
    emit(DeleteSectionItemLoading(sectionItemId: sectionItemId));

    final Either<Failure, void> result = await _courseSectionsRepo
        .deleteSectionItem(
          courseId: courseId,
          sectionId: sectionId,
          sectionItemId: sectionItemId,
        );

    result.fold(
      (failure) => emit(DeleteSectionItemFailure(errMessage: failure.message)),
      (_) => emit(DeleteSectionItemSuccess()),
    );
  }

  // -----------------------
  // Delete an entire section
  // -----------------------
  Future<void> deleteSection({
    required String courseId,
    required String sectionId,
  }) async {
    emit(DeleteSectionLoading(sectionId: sectionId));

    final Either<Failure, void> result = await _courseSectionsRepo
        .deleteSection(courseId: courseId, sectionId: sectionId);

    result.fold(
      (failure) => emit(DeleteSectionFailure(errMessage: failure.message)),
      (_) => emit(DeleteSectionSuccess()),
    );
  }
}
