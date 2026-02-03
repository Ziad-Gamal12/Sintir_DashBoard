import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sintir_dashboard/Core/Managers/user_cubit/user_cubit.dart';
import 'package:sintir_dashboard/Core/Services/HiveService.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/Themes/app_theme.dart';
import 'package:sintir_dashboard/Core/Themes/theme_cubit.dart';
import 'package:sintir_dashboard/Core/Utils/App_router.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';
import 'package:sintir_dashboard/constant.dart';
import 'package:sintir_dashboard/firebase_options.dart';
import 'package:sintir_dashboard/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Supabase.initialize(url: supaBaseUrl, anonKey: supaAnonKey),
    _initStorageAndHive(),
  ]);

  setup_Getit();

  runApp(
    BlocProvider(
      create: (context) => UserCubit(authRepo: getIt<AuthRepo>()),
      child: const SintirDashboard(),
    ),
  );
}

Future<void> _initStorageAndHive() async {
  await Future.wait([
    Hive.initFlutter(),
    Hive_Services.init(),
    _initHydratedStorage(),
  ]);
}

Future<void> _initHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
}

class SintirDashboard extends StatefulWidget {
  const SintirDashboard({super.key});

  @override
  State<SintirDashboard> createState() => _SintirDashboardState();
}

class _SintirDashboardState extends State<SintirDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().asyncUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocListener<UserCubit, UserState>(
            listenWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType,
            listener: (context, state) {
              App_router.router.refresh();
            },
            child: MaterialApp.router(
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
            ),
          );
        },
      ),
    );
  }
}
