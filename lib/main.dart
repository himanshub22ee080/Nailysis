// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart'; // Import camera
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/theme_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/routes/app_router.dart';
import 'package:Nailysis/theme/app_theme.dart';

List<CameraDescription> cameras = []; // Make cameras globally accessible

Future<void> main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  runApp(const NailysisApp());
}

class NailysisApp extends StatelessWidget {
  const NailysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method is unchanged)
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