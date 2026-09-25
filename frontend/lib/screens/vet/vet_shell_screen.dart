import 'package:flutter/material.dart';
import 'package:frontend/widgets/vet_bottom_navigation.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/notification_header_button.dart';

class VetShellScreen extends StatelessWidget {
  final Widget child;

  const VetShellScreen({super.key, required this.child});

  static const Color brandDarkBlue = Color.fromARGB(255, 18, 134, 78);

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // Tab 0: Vet Sick Reports
    if (location.startsWith('/vet-reports') ||
        location.startsWith('/vet-response-sent')) {
      return 0;
    }

    // Tab 1: Farmers List & Detail
    if (location.startsWith('/my-farmers') ||
        location.startsWith('/farmer-detail')) {
      return 1;
    }

    // Tab 3: Vet Profile
    if (location.startsWith('/vet-profile')) {
      return 3;
    }

    // Tab 2: Dashboard & Vet Notifications default to Home/Dashboard
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

  String _getPageTitle(BuildContext context, int activeIndex) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/vet-notifications')) return 'VacTracker';
    if (location.startsWith('/farmer-detail')) return 'VacTracker';
    if (location.startsWith('/vet-response-sent')) return 'VacTracker';

    switch (activeIndex) {
      case 0:
        return 'VacTracker';
      case 1:
        return 'VacTracker';
      case 2:
        return 'VacTracker';
      case 3:
        return 'VacTracker';
      default:
        return 'VacTracker Vet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final languageCode = _extractLanguage(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(context, currentIndex),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 14, 87, 9),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          NotificationHeaderButton(
            languageCode: languageCode,
            color: const Color.fromARGB(255, 12, 12, 12),
            showCount: true, // Shows badge count for vets
            notificationsRoute: '/vet-notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: currentIndex,
        languageCode: languageCode,
      ),
    );
  }
}
