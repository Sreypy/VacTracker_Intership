import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/auth_choice_page.dart';
import 'package:frontend/screens/auth/login_otp_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/farmer/farmer_register_page.dart';
import 'package:frontend/screens/language_page.dart';
import 'package:frontend/screens/role.dart';
import 'package:frontend/screens/vet/vet_register_page.dart';
import 'package:frontend/screens/welcome_page.dart';
import 'package:go_router/go_router.dart';

// Define the clear, explicit web-like URL paths
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguagePage(),
    ),
    GoRoute(
      path: '/role/:lang', // ':lang' dynamically holds 'en' or 'kh'
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return RoleSelectionPage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/auth-choice/:role/:lang',

      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'farmer';

        final language = state.pathParameters['lang'] ?? 'en';

        return AuthChoicePage(role: role, languageCode: language);
      },
    ),
    GoRoute(
      path: '/login/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';

        return LoginScreen(languageCode: language);
      },
    ),
    GoRoute(
      path: '/login-otp',

      builder: (context, state) {
        final phone = (state.extra as String?) ?? '';

        return LoginOtpScreen(phone: phone);
      },
    ),

    // Route for Farmer Registration
    GoRoute(
      path: '/register/farmer/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return FarmerRegisterPage(languageCode: language);
      },
    ),
    // Route for Vet Registration
    GoRoute(
      path: '/register/vet/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return VetRegisterPage(languageCode: language);
      },
    ),
  ],
);

void main() {
  runApp(const VacTrackerApp());
}

class VacTrackerApp extends StatelessWidget {
  const VacTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VacTracker',
      theme: ThemeData(fontFamily: 'Sans-Serif'),
      routerConfig: _router, // Connect GoRouter engine here
    );
  }
}
