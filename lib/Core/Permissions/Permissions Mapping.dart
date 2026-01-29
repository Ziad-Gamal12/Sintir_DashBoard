import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

enum Permission {
  viewUsers,
  createUser,
  editUser,
  deleteUser,
  banUser,
  viewCourses,
  createCourse,
  editCourse,
  deleteCourse,
  publishCourse,
  viewTickets,
  replyTickets,
  changeTicketStatus,
  viewAnalytics,
  exportData,
}

enum Role { admin, coursesManager, usersManager, support, viewer }

class PermissionsManager {
  static Role _mapStringToRole(String roleStr) {
    if (roleStr == BackendEndpoints.adminRole) return Role.admin;
    if (roleStr == BackendEndpoints.coursesManagerrRole)
      return Role.coursesManager;
    if (roleStr == BackendEndpoints.usersManagerrRole) return Role.usersManager;
    if (roleStr == BackendEndpoints.supportRole) return Role.support;
    return Role.viewer;
  }

  // 2. Defined Permission Sets
  static final Map<Role, Set<Permission>> _rolePermissions = {
    Role.coursesManager: {
      Permission.viewCourses,
      Permission.publishCourse,
      Permission.editCourse,
      Permission.deleteCourse,
    },
    Role.usersManager: {
      Permission.viewUsers,
      Permission.editUser,
      Permission.deleteUser,
    },
    Role.support: {
      Permission.viewTickets,
      Permission.replyTickets,
      Permission.changeTicketStatus,
      Permission.banUser,
    },
    Role.viewer: {
      Permission.viewUsers,
      Permission.viewTickets,
      Permission.viewCourses,
      Permission.viewAnalytics,
    },
  };

  static bool can(
    Permission permission, {
    required String role,
    required String status,
  }) {
    if (status != BackendEndpoints.activeStatus) return false;

    final userRole = _mapStringToRole(role);

    if (userRole == Role.admin) return true;

    return _rolePermissions[userRole]?.contains(permission) ?? false;
  }
}
