import 'package:sintir_dashboard/Core/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class UsersFilterConstants {
  static List<FilterOptionEntity> getUsersStatusFilters() {
    return [
      FilterOptionEntity(labelAr: "الكل", valueEn: ""),
      FilterOptionEntity(
        labelAr: "مفعل",
        valueEn: BackendEndpoints.activeStatus,
      ),
      FilterOptionEntity(
        labelAr: "غير مفعل",
        valueEn: BackendEndpoints.inActiveStatus,
      ),
      FilterOptionEntity(
        labelAr: "قيد المراجعة",
        valueEn: BackendEndpoints.pendingStatus,
      ),
      FilterOptionEntity(
        labelAr: "مرفوض",
        valueEn: BackendEndpoints.rejectedStatus,
      ),
      FilterOptionEntity(
        labelAr: "محظور",
        valueEn: BackendEndpoints.blockedStatus,
      ),
    ];
  }

  static List<FilterOptionEntity> getRolesFilters() {
    return [
      FilterOptionEntity(labelAr: "الكل", valueEn: ""),
      FilterOptionEntity(labelAr: "مدير", valueEn: BackendEndpoints.adminRole),
      FilterOptionEntity(
        labelAr: "مدير للدورات",
        valueEn: BackendEndpoints.coursesManagerrRole,
      ),
      FilterOptionEntity(
        labelAr: "مدير للمستخدمين",
        valueEn: BackendEndpoints.usersManagerrRole,
      ),
      FilterOptionEntity(
        labelAr: "مدير للدعم",
        valueEn: BackendEndpoints.supportRole,
      ),
      FilterOptionEntity(
        labelAr: "معلم",
        valueEn: BackendEndpoints.teacherRole,
      ),
      FilterOptionEntity(
        labelAr: "طالب",
        valueEn: BackendEndpoints.studentRole,
      ),
      FilterOptionEntity(labelAr: "مستخدم", valueEn: ""),
    ];
  }

  static List<FilterOptionEntity> getGenderFilters() {
    return [
      FilterOptionEntity(labelAr: "الكل", valueEn: ""),
      FilterOptionEntity(labelAr: "ذكر", valueEn: "Male"),
      FilterOptionEntity(labelAr: "انثى", valueEn: "Female"),
    ];
  }
}
