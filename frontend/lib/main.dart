import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/screens/auth/auth_choice_page.dart';
import 'package:frontend/screens/auth/login_otp_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/farmer/add_flock_page.dart';
import 'package:frontend/screens/farmer/farmer_dashboard_page.dart';
import 'package:frontend/screens/farmer/farmer_profile_page.dart';
import 'package:frontend/screens/farmer/farmer_register_page.dart';
import 'package:frontend/screens/farmer/flock_detail_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step1_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step2_page.dart';
import 'package:frontend/screens/farmer/log_vaccination_step3_page.dart';
import 'package:frontend/screens/farmer/my_sick_reports_screen.dart';
import 'package:frontend/screens/farmer/notification_screen.dart';
import 'package:frontend/screens/farmer/sick_report.dart';
import 'package:frontend/screens/farmer/sick_report_detail_screen.dart';
import 'package:frontend/screens/farmer/subscription_page.dart';
import 'package:frontend/screens/farmer/vaccination_history.dart';
import 'package:frontend/screens/farmer/vaccine_library_detail_page.dart';
import 'package:frontend/screens/farmer/vaccine_library_page.dart';
import 'package:frontend/screens/language_page.dart';
import 'package:frontend/screens/role.dart';
import 'package:frontend/screens/vet/farmer_detail_page.dart';
import 'package:frontend/screens/vet/my_farmers_page.dart';
import 'package:frontend/screens/vet/sick_report_detail_screen.dart';
import 'package:frontend/screens/vet/sick_reports_screen.dart';
import 'package:frontend/screens/vet/vet_dashboard_page.dart';
import 'package:frontend/screens/vet/vet_notification_screen.dart';
import 'package:frontend/screens/vet/vet_profile_page.dart';
import 'package:frontend/screens/vet/vet_register_page.dart';
import 'package:frontend/screens/vet/vet_response_sent_screen.dart';
import 'package:frontend/screens/welcome_page.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _farmerShellNavigatorKey =
    GlobalKey<NavigatorState>();

/// Shared Shell wrapper that keeps Header and Footer persistent for ALL Farmer features
class FarmerShellLayout extends StatelessWidget {
  final Widget child;

  const FarmerShellLayout({super.key, required this.child});

  /// Keeps the relevant footer tab active even when inside deep sub-features
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // Tab 0: Sick Reports & Sick Report Forms
    if (location.startsWith('/my-sick-reports') ||
        location.startsWith('/sick-report')) {
      return 0;
    }

    // Tab 1: Log Vaccine Steps
    if (location.startsWith('/log-vaccination')) {
      return 1;
    }

    // Tab 3: Vaccine Library & Detail
    if (location.startsWith('/vaccine-library')) {
      return 3;
    }

    // Tab 4: Farmer Profile & Subscriptions
    if (location.startsWith('/farmer-profile') ||
        location.startsWith('/subscription')) {
      return 4;
    }

    // Tab 2: Dashboard, Flocks, and Notifications default to Home/Dashboard
    return 2;
  }

  String _extractLanguage(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    if (uri.queryParameters.containsKey('lang')) {
      return uri.queryParameters['lang']!;
    }
    if (uri.pathSegments.isNotEmpty) {
      final last = uri.pathSegments.last;
      if (last == 'en' || last == 'km' || last == 'kh') {
        return last;
      }
    }
    return 'en';
  }

  String _getHeaderTitle(BuildContext context, int activeIndex) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/notifications')) return 'Notifications';
    if (location.startsWith('/add-flock')) return 'Add Flock';
    if (location.startsWith('/flock-detail')) return 'Flock Details';
    if (location.startsWith('/sick-report')) return 'Report Sick Flock';
    if (location.startsWith('/subscription')) return 'Subscription';

    switch (activeIndex) {
      case 0:
        return 'Sick Reports';
      case 1:
        return 'Log Vaccine';
      case 2:
        return 'VacTracker';
      case 3:
        return 'Vaccine Library';
      case 4:
        return 'Profile';
      default:
        return 'VacTracker';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final languageCode = _extractLanguage(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getHeaderTitle(context, currentIndex),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF034418),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          NotificationHeaderButton(
            languageCode: languageCode,
            color: const Color(0xFF034418),
            notificationsRoute: '/notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child, // Swaps content dynamically
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: currentIndex,
        languageCode: languageCode,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // --- Public / Authentication Routes ---
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguagePage(),
    ),
    GoRoute(
      path: '/role/:lang',
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
      path: '/register/farmer/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return FarmerRegisterPage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/register/vet/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return VetRegisterPage(languageCode: language);
      },
    ),

    // =========================================================================
    // ALL FARMER FEATURES (Persistent Header & Persistent Footer Shell)
    // =========================================================================
    ShellRoute(
      navigatorKey: _farmerShellNavigatorKey,
      builder: (context, state, child) {
        return FarmerShellLayout(child: child);
      },
      routes: [
        // Tab 2: Dashboard
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

        // Notifications
        GoRoute(
          path: '/notifications/:lang',
          builder: (context, state) {
            final language = state.pathParameters['lang'] ?? 'en';
            return NotificationScreen(languageCode: language);
          },
        ),

        // Tab 0: Sick Reports & Sick Report Flows
        GoRoute(
          path: '/my-sick-reports',
          builder: (context, state) => MySickReportsScreen(
            languageCode: state.uri.queryParameters['lang'] ?? 'en',
          ),
        ),
        GoRoute(
          path: '/sick-report',
          builder: (context, state) {
            final languageCode = state.uri.queryParameters['lang'] ?? 'en';
            return SickReportScreen(languageCode: languageCode);
          },
        ),
        GoRoute(
          path: '/my-sick-reports/:reportId',
          builder: (context, state) => FarmerSickReportDetailScreen(
            reportId: int.tryParse(state.pathParameters['reportId'] ?? '') ?? 0,
            languageCode: state.uri.queryParameters['lang'] ?? 'en',
          ),
        ),

        // Tab 1: Log Vaccine Steps
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
            final vaccineId = state.uri.queryParameters['vaccineId'] ?? '';
            final vaccinationId = state.uri.queryParameters['vaccinationId'];

            return LogVaccinationStep2Page(
              selectedFlockName: flockName,
              flockId: flockId,
              languageCode: language,
              selectedVaccineId: vaccineId,
              scheduledVaccinationId: vaccinationId,
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
            final summaryData = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            return LogVaccinationStep3Page(
              flockId: flockId,
              vaccineId: vaccineId,
              languageCode: language,
              flockName: flockName,
              summaryData: summaryData,
            );
          },
        ),

        // Tab 3: Vaccine Library & Details
        GoRoute(
          path: '/vaccine-library/:lang',
          builder: (context, state) {
            final language = state.pathParameters['lang'] ?? 'km';
            return VaccineLibraryPage(languageCode: language);
          },
        ),
        GoRoute(
          path: '/vaccine-library-detail/:articleId/:lang',
          builder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            final language = state.pathParameters['lang'] ?? 'km';
            return VaccineLibraryDetailPage(
              articleId: articleId,
              languageCode: language,
            );
          },
        ),

        // Tab 4: Profile & Subscriptions
        GoRoute(
          path: '/farmer-profile/:lang',
          builder: (context, state) {
            final language = state.pathParameters['lang'] ?? 'en';
            return FarmerProfilePage(languageCode: language);
          },
        ),
        GoRoute(
          path: '/subscription/:lang',
          builder: (context, state) {
            final language = state.pathParameters['lang'] ?? 'en';
            return SubscriptionPage(languageCode: language);
          },
        ),

        // Flock Management Routes
        GoRoute(
          path: '/add-flock/:lang',
          builder: (context, state) {
            final language = state.pathParameters['lang'] ?? 'en';
            final editingFlock = state.extra is Flock
                ? state.extra as Flock
                : null;
            return AddFlockPage(
              languageCode: language,
              editingFlock: editingFlock,
            );
          },
        ),
        GoRoute(
          path: '/flock-detail/:flockId/vaccine-history',
          builder: (context, state) {
            final flockId = state.pathParameters['flockId'] ?? '';
            final languageCode = state.uri.queryParameters['lang'] ?? 'km';

            return VaccinationHistoryScreen(
              flockId: flockId,
              languageCode: languageCode,
            );
          },
        ),
        GoRoute(
          path: '/flock-detail/:flockId/:lang',
          builder: (context, state) {
            final flockId =
                int.tryParse(state.pathParameters['flockId'] ?? '') ?? 0;
            final language = state.pathParameters['lang'] ?? 'en';

            return FlockDetailPage(flockId: flockId, languageCode: language);
          },
        ),
      ],
    ),

    // =========================================================================
    // VET ROUTES (Independent of Farmer Shell)
    // =========================================================================
    GoRoute(
      path: '/vet-dashboard',
      builder: (context, state) {
        final language = state.uri.queryParameters['lang'] ?? 'en';
        return VetDashboardPage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/vet-reports',
      builder: (context, state) {
        final language = state.uri.queryParameters['lang'] ?? 'en';
        return VetSickReportsScreen(languageCode: language);
      },
    ),
    GoRoute(
      path: '/vet-reports/:reportId',
      builder: (context, state) {
        final reportId = state.pathParameters['reportId'] ?? '';
        final language = state.uri.queryParameters['lang'] ?? 'en';
        return VetSickReportDetailScreen(
          reportId: reportId,
          languageCode: language,
        );
      },
    ),
    GoRoute(
      path: '/vet-response-sent/:reportId',
      builder: (context, state) {
        final reportId = state.pathParameters['reportId'] ?? '';
        final language = state.uri.queryParameters['lang'] ?? 'en';
        return VetResponseSentScreen(
          reportId: reportId,
          languageCode: language,
        );
      },
    ),
    GoRoute(
      path: '/my-farmers/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return MyFarmersPage(languageCode: language);
      },
    ),
    GoRoute(
      path: '/farmer-detail/:farmerId/:lang',
      builder: (context, state) {
        final farmerId = int.parse(state.pathParameters['farmerId'] ?? '0');
        final language = state.pathParameters['lang'] ?? 'en';
        return FarmerDetailPage(farmerId: farmerId, languageCode: language);
      },
    ),
    GoRoute(
      path: '/vet-profile/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return VetProfileScreen(currentLanguage: language);
      },
    ),
    GoRoute(
      path: '/vet-notifications/:lang',
      builder: (context, state) {
        final language = state.pathParameters['lang'] ?? 'en';
        return VetNotificationScreen(languageCode: language);
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
      routerConfig: _router,
    );
  }
}
