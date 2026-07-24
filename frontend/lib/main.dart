import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/auth_choice_page.dart';
import 'package:frontend/screens/auth/login_otp_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/screens/farmer/add_flock_page.dart';
import 'package:frontend/screens/farmer/farmer_dashboard_page.dart';
import 'package:frontend/screens/farmer/farmer_profile_page.dart';
import 'package:frontend/screens/farmer/farmer_register_page.dart';
import 'package:frontend/screens/farmer/flock_detail_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step1_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step2_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step3_page.dart';
import 'package:frontend/screens/farmer/notification_screen.dart';
import 'package:frontend/screens/language_page.dart';
import 'package:frontend/screens/role.dart';
import 'package:frontend/screens/vet/vet_dashboard_page.dart';
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
      path: '/login/:role/:lang',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'farmer';
        final language = state.pathParameters['lang'] ?? 'en';

        return LoginScreen(role: role, languageCode: language);
      },
    ),
    GoRoute(
      path: '/login-otp',
      builder: (context, state) {
        final extra = state.extra;
        var phone = '';
        var language = 'en';

        if (extra is Map<String, String>) {
          phone = extra['phone'] ?? '';
          language = extra['lang'] ?? 'en';
        } else if (extra is String) {
          phone = extra;
        }

        return LoginOtpScreen(phone: phone, languageCode: language);
      },
    ),
    GoRoute(
      path: '/farmer-dashboard',
      builder: (context, state) {
        final language = state.uri.queryParameters['lang'] ?? 'en';
        final showSaved = state.uri.queryParameters['saved'] == 'true';
        return FarmerDashboardPage(
          languageCode: language,
          showSavedMessage: showSaved,
        );
      },
    ),
    GoRoute(
      path: '/vet-dashboard',
      builder: (context, state) {
        final language = state.uri.queryParameters['lang'] ?? 'en';
        return VetDashboardPage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/add-flock/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        final editingFlock = state.extra is Flock ? state.extra as Flock : null;
        return AddFlockPage(languageCode: language, editingFlock: editingFlock);
      },
    ),

    // --- Log Vaccination Step 1 ---
    GoRoute(
      path: '/log-vaccination-step1/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'km';
        return LogVaccinationStep1Page(languageCode: language);
      },
    ),
    GoRoute(
      path: '/log-vaccination-step2/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'km';
        final flockName =
            state.uri.queryParameters['batchTitle'] ?? 'Flock B-42';
        final flockId = state.uri.queryParameters['flockId'] ?? '';

        return LogVaccinationStep2Page(
          selectedFlockName: Uri.decodeComponent(flockName),
          flockId: flockId,
          languageCode: language,
        );
      },
    ),
    GoRoute(
      path: '/log-vaccination-step3/:vaccineId/:lang',
      builder: (context, state) {
        final vaccineId = state.pathParameters['vaccineId'] ?? '';
        final language = state.pathParameters['lang'] ?? 'km';
        final flockId = state.uri.queryParameters['flockId'] ?? '';
        final flockName = state.uri.queryParameters['batchTitle'] ?? '';

        return LogVaccinationStep3Page(
          flockId: flockId,
          vaccineId: vaccineId,
          languageCode: language,
          flockName: Uri.decodeComponent(flockName),
        );
      },
    ),
    GoRoute(
      path: '/farmer-profile/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return FarmerProfilePage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/notifications/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return NotificationScreen(languageCode: language);
      },
    ),

    // --- Flock Detail Route ---
    GoRoute(
      path: '/flock-detail/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        final flock = state.extra is Flock ? state.extra as Flock : null;
        return FlockDetailPage(
          batchTitle: flock?.batchName ?? 'Batch A-102',
          languageCode: language,
        );
      },
    ),
    GoRoute(
      path: '/flock-detail/:batchTitle/:lang',
      builder: (context, state) {
        final batchTitle = state.pathParameters['batchTitle'] ?? 'Batch A-102';
        final language = state.pathParameters['lang'] ?? 'en';
        return FlockDetailPage(
          batchTitle: Uri.decodeComponent(batchTitle),
          languageCode: language,
        );
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
