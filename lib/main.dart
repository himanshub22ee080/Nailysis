import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/theme_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/routes/app_router.dart';
import 'package:Nailysis/theme/app_theme.dart';

void main() {
  runApp(const NailysisApp());
}

class NailysisApp extends StatelessWidget {
  const NailysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Nailysis',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
