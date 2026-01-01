import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileviewnavigationsrequirmentsentity.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';

class CourseFileEntity {
  String title;
  String fileUrl;
  String description;
  String id;
  File? file;
  String? type;
  String preffixImage = Assets.assetsIconsSVGIconsCustomFileIcon;

  CourseFileEntity({
    this.type = "File",
    required this.description,
    required this.title,
    required this.id,
    this.file,
    required this.fileUrl,
  });
  void ontap({
    required BuildContext context,
    required Coursefileviewnavigationsrequirmentsentity item,
    required CourseEntity course,
  }) {}
}
