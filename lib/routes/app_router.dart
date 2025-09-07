import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Nailysis/screens/splash_screen.dart';
import 'package:Nailysis/screens/login_screen.dart';
import 'package:Nailysis/screens/register_screen.dart';
import 'package:Nailysis/screens/onboarding_screen.dart';
import 'package:Nailysis/screens/home_screen.dart';
import 'package:Nailysis/screens/guided_capture_screen.dart';
import 'package:Nailysis/screens/results_screen.dart';
import 'package:Nailysis/screens/patients_screen.dart';
import 'package:Nailysis/screens/settings_screen.dart';
import 'package:Nailysis/screens/user_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'capture',
            name: 'capture',
            builder: (context, state) => const GuidedCaptureScreen(),
          ),
          GoRoute(
            path: 'results',
            name: 'results',
            builder: (context, state) => const ResultsScreen(),
          ),
          GoRoute(
            path: 'measurements',
            name: 'measurements',
            builder: (context, state) => const PatientsScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
