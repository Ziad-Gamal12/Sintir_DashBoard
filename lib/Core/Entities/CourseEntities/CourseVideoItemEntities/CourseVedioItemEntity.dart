import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVideoviewnavigationsrequirmentsentity.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';

class CourseVideoItemEntity {
  String title, vedioUrl;
  int durationTime;
  String id;
  File? file;
  String? type;
  String preffixImage = Assets.assetsIconsSVGIconsVideoIcon;
  void ontap({
    required BuildContext context,
    required CourseVideoViewNavigationsRequirmentsEntity requires,
    required CourseEntity course,
  }) {}

  CourseVideoItemEntity({
    required this.title,
    required this.vedioUrl,
    required this.id,
    required this.durationTime,
    this.file,
    this.type = "Video",
  });
}
