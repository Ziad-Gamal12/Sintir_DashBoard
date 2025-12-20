import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sintir_dashboard/Core/Services/BlocObserver.dart';
import 'package:sintir_dashboard/Core/Services/HiveService.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/Themes/app_theme.dart';
import 'package:sintir_dashboard/Core/Themes/theme_cubit.dart';
import 'package:sintir_dashboard/Core/Utils/App_router.dart';
import 'package:sintir_dashboard/Core/widgets/PrivacyWrapper.dart';
import 'package:sintir_dashboard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(appDocDir.path),
  );
  HydratedBloc.storage = storage;
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Hive.initFlutter(),
    Hive_Services.init(),
  ]);
  Bloc.observer = Custom_Blocobserver();
  setup_Getit();
  runApp(const Portal(child: PrivacyWrapper(child: SintirDashboard())));
}

class SintirDashboard extends StatelessWidget {
  const SintirDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en'), const Locale('ar')],
            locale: Locale("ar"),
            debugShowCheckedModeBanner: false,
            routerConfig: App_router.router,
          );
        },
      ),
    );
  }
}
