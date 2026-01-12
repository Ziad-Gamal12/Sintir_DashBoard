import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Manager/courses_management_cubit/courses_management_cubit.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentBodyHandler.dart';

class CoursesManagmentBody extends StatelessWidget {
  const CoursesManagmentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoursesManagementCubit(coursesrepo: getIt<Coursesrepo>()),
      child: CoursesManagmentBodyHandler(),
    );
  }
}
