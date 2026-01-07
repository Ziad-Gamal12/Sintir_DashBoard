import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorProfileBody.dart';

class ContentCreatorProfile extends StatelessWidget {
  const ContentCreatorProfile({super.key, required this.contentcreaterentity});
  static const routeName = '/ContentCreatorProfile';
  final ContentCreatorEntity contentcreaterentity;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBartitle: "تفاصيل المعلم"),
      body: BlocProvider(
        create: (context) => ContentCreatorCoursesCubit(
          contentCreatorProfileRepo: getIt<ContentCreatorProfileRepo>(),
        ),
        child: ContentCreatorProfileBody(
          contentcreaterentity: contentcreaterentity,
        ),
      ),
    );
  }
}
