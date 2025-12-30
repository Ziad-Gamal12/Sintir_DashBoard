// Location: Features/CoursesManagment/Presentation/Manager/CourseFilterConstants.dart
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart'; // Adjust path

class CourseFilterConstants {
  static List<FilterOptionEntity> getStatusFilters() {
    return [
      FilterOptionEntity(labelAr: "الكل", valueEn: "All"),
      FilterOptionEntity(
        labelAr: "منشور",
        valueEn: BackendEndpoints.coursePublishedState,
      ),
      FilterOptionEntity(
        labelAr: "قيد المراجعة",
        valueEn: BackendEndpoints.coursePendingState,
      ),
      FilterOptionEntity(
        labelAr: "مرفوض",
        valueEn: BackendEndpoints.coursedeclinedState,
      ),
      FilterOptionEntity(
        labelAr: "محذوف",
        valueEn: BackendEndpoints.courseDeletedState,
      ),
    ];
  }

  static List<FilterOptionEntity> getLanguageFilters() {
    return [
      FilterOptionEntity(labelAr: "اللغة", valueEn: "All"),
      FilterOptionEntity(labelAr: "العربية", valueEn: "Arabic"),
      FilterOptionEntity(labelAr: "الإنجليزية", valueEn: "English"),
      FilterOptionEntity(labelAr: "الفرنسية", valueEn: "French"),
    ];
  }

  static List<FilterOptionEntity> getSubjectFilters() {
    return [
      FilterOptionEntity(labelAr: "اللغة العربية", valueEn: "Arabic"),
      FilterOptionEntity(labelAr: "اللغة الإنجليزية", valueEn: "English"),
      FilterOptionEntity(labelAr: "اللغة الفرنسية", valueEn: "French"),
      FilterOptionEntity(labelAr: "اللغة الإيطالية", valueEn: "Italian"),
      FilterOptionEntity(labelAr: "اللغة الإسبانية", valueEn: "Spanish"),
      FilterOptionEntity(labelAr: "الرياضيات", valueEn: "Mathematics"),
      FilterOptionEntity(labelAr: "الفيزياء", valueEn: "Physics"),
      FilterOptionEntity(labelAr: "الكيمياء", valueEn: "Chemistry"),
      FilterOptionEntity(labelAr: "الأحياء", valueEn: "Biology"),
      FilterOptionEntity(
        labelAr: "العلوم البيولوجية",
        valueEn: "Biological Science",
      ),
      FilterOptionEntity(labelAr: "العلوم", valueEn: "Science"),
      FilterOptionEntity(labelAr: "الفلسفة", valueEn: "Philosophy"),
      FilterOptionEntity(labelAr: "التاريخ", valueEn: "History"),
      FilterOptionEntity(labelAr: "الجغرافيا", valueEn: "Geography"),
      FilterOptionEntity(labelAr: "علوم الحاسوب", valueEn: "Computer Science"),
      FilterOptionEntity(labelAr: "أخرى", valueEn: "Other"),
    ];
  }

  static List<FilterOptionEntity> getLevelFilters() {
    return [
      FilterOptionEntity(
        labelAr: "الصف الأول الابتدائي",
        valueEn: "1st Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثاني الابتدائي",
        valueEn: "2nd Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثالث الابتدائي",
        valueEn: "3rd Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الرابع الابتدائي",
        valueEn: "4th Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الخامس الابتدائي",
        valueEn: "5th Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف السادس الابتدائي",
        valueEn: "6th Grade Primary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الأول الإعدادي",
        valueEn: "1st Grade Preparatory",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثاني الإعدادي",
        valueEn: "2nd Grade Preparatory",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثالث الإعدادي",
        valueEn: "3rd Grade Preparatory",
      ),
      FilterOptionEntity(
        labelAr: "الصف الأول الثانوي",
        valueEn: "1st Grade Secondary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثاني الثانوي",
        valueEn: "2nd Grade Secondary",
      ),
      FilterOptionEntity(
        labelAr: "الصف الثالث الثانوي",
        valueEn: "3rd Grade Secondary",
      ),
    ];
  }
}
