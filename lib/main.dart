import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sintir_dashboard/Core/Services/HiveService.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/Themes/app_theme.dart';
import 'package:sintir_dashboard/Core/Themes/theme_cubit.dart';
import 'package:sintir_dashboard/Core/Utils/App_router.dart';
import 'package:sintir_dashboard/constant.dart';
import 'package:sintir_dashboard/firebase_options.dart';
import 'package:sintir_dashboard/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  HydratedBloc.storage = storage;
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Supabase.initialize(url: supaBaseUrl, anonKey: supaAnonKey),
    Hive.initFlutter(),
    Hive_Services.init(),
  ]);

  setup_Getit();
  runApp(SintirDashboard());
}

class SintirDashboard extends StatelessWidget {
  const SintirDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: Locale("ar"),
            debugShowCheckedModeBanner: false,
            routerConfig: App_router.router,
          );
        },
      ),
    );
  }
}
