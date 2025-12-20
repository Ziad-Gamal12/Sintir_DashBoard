// ignore_for_file: file_names, camel_case_types

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class Custom_Blocobserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      log("$transition");
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      log("$change");
    }
  }
}
