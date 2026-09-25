import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/farmer_bottom_navigation.dart';
import '../../widgets/notification_header_button.dart';

class FarmerShellScreen extends StatelessWidget {
  final Widget child;

  const FarmerShellScreen({super.key, required this.child});

  /// Maps every route URL to one of the 5 footer tabs (0 to 4).
  /// NEVER return a number >= 5 or BottomNavigationBar will crash.
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

    // Tab 3: Vaccine Library & Articles
    if (location.startsWith('/vaccine-library')) {
      return 3;
    }

    // Tab 4: Farmer Profile & Subscriptions
    if (location.startsWith('/farmer-profile') ||
        location.startsWith('/subscription')) {
      return 4;
    }

    // Tab 2: Dashboard, Flock Management, and Notifications default to Home/Dashboard
    return 2;
  }

  /// Extracts language code from query (?lang=xx) or path (/xx)
  String _extractLanguageCode(BuildContext context) {
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

  /// Displays the correct title on the AppBar based on the active screen
  String _getPageTitle(BuildContext context, int activeTab) {
    final String location = GoRouterState.of(context).uri.path;

    // Specific sub-page titles
    if (location.startsWith('/notifications')) return 'Notifications';
    if (location.startsWith('/add-flock')) return 'Add Flock';
    if (location.startsWith('/edit-flock')) return 'Edit Flock';
    if (location.startsWith('/flock-detail')) return 'Flock Details';
    if (location.startsWith('/sick-report')) return 'Report Sick Flock';
    if (location.startsWith('/subscription')) return 'Subscription';
    if (location.startsWith('/log-vaccination-step2') ||
        location.startsWith('/log-vaccination-step3')) {
      return 'Log Vaccine Details';
    }
    if (location.contains('/vaccine-library-detail')) {
      return 'Article Details';
    }
    if (location.contains('/vaccine-library')) {
      return 'Vaccine Library';
    }
    if (location.contains('/farmer-profile')) {
      return 'Profile';
    }
    if (location.contains('/my-sick-reports')) {
      return 'Sick Reports';
    }
    if (location.contains('/log-vaccination-step1')) {
      return 'Log Vaccine';
    }
    if (location.contains('/log-vaccination-step2')) {
      return 'Log Vaccine Details';
    }
    if (location.contains('/log-vaccination-step3')) {
      return 'Log Vaccine Details';
    }
    if (location.contains('/farmer-dashboard')) {
      return 'VacTracker';
    }

    // Default primary tab titles
    switch (activeTab) {
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
    final languageCode = _extractLanguageCode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(context, currentIndex),
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
      body: child, // Only this child content area updates on navigation
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: currentIndex,
        languageCode: languageCode,
      ),
    );
  }
}
