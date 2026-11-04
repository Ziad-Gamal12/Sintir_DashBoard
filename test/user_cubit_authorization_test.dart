import 'package:flutter_test/flutter_test.dart';
import 'package:sintir_dashboard/Core/Managers/user_cubit/user_cubit.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

void main() {
  UserEntity user({required String role, required String status}) =>
      UserEntity.empty()
        ..role = role
        ..status = status;

  test('only active dashboard roles are authorized', () {
    for (final role in ['Admin', 'CoursesManager', 'UsersManager', 'Support']) {
      expect(
        isDashboardUserAuthorized(user(role: role, status: 'Active')),
        isTrue,
        reason: '$role should retain dashboard access while active.',
      );
    }
  });

  test('student, teacher, and unknown roles are rejected', () {
    for (final role in ['Student', 'Teacher', '', 'Unknown']) {
      expect(
        isDashboardUserAuthorized(user(role: role, status: 'Active')),
        isFalse,
        reason: '$role must not access the management dashboard.',
      );
    }
  });

  test('inactive admin sessions are rejected', () {
    for (final status in [
      'Pending',
      'Blocked',
      'Rejected',
      'InActive',
      'active',
      'ACTIVE',
      '',
    ]) {
      expect(
        isDashboardUserAuthorized(user(role: 'Admin', status: status)),
        isFalse,
        reason: 'Admin with status $status must not remain authorized.',
      );
    }
  });
}
