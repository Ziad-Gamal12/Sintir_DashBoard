import 'package:sintir_dashboard/Core/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class FilterTicketsContants {
  static List<FilterOptionEntity> getStatusFilters() {
    return [
      FilterOptionEntity(labelAr: "الكل", valueEn: ""),
      FilterOptionEntity(labelAr: "مفعل", valueEn: BackendEndpoints.open),
      FilterOptionEntity(
        labelAr: "قيد الأنتظار",
        valueEn: BackendEndpoints.pending,
      ),
      FilterOptionEntity(
        labelAr: "قيد التنفيذ",
        valueEn: BackendEndpoints.inProgress,
      ),
      FilterOptionEntity(labelAr: "مكتمل", valueEn: BackendEndpoints.resolved),
      FilterOptionEntity(labelAr: "عاجل", valueEn: BackendEndpoints.urgent),
      FilterOptionEntity(
        labelAr: "اولوية عالية",
        valueEn: BackendEndpoints.highPriority,
      ),
      FilterOptionEntity(labelAr: "مغلق", valueEn: BackendEndpoints.closed),
    ];
  }
}
