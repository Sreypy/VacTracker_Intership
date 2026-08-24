import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/notification_service.dart';

/// Reusable bottom footer navigation for all Farmer screens.
///
/// Gives every Farmer screen one consistent footer with five tabs, in order:
///   0. Sick Reports  (assignment icon, shows unread-notification badge)
///   1. Log Vaccine   (vaccines icon)
///   2. Dashboard     (home icon, centre pill highlight)
///   3. Library       (menu_book icon)
///   4. Profile       (person icon)
///
/// Navigation uses `context.go` (replace) so switching tabs never stacks up
/// duplicate pages in the GoRouter stack. Pass the selected tab via
/// [currentIndex] and the active language via [languageCode].
class FarmerBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final String languageCode;

  const FarmerBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.languageCode,
  });

  @override
  State<FarmerBottomNavigation> createState() =>
      _FarmerBottomNavigationState();
}

class _FarmerBottomNavigationState extends State<FarmerBottomNavigation> {
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color badgeRed = Color(0xFFA80000);

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService().fetchUnreadCount();
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (_) {
      // Optional badge only; footer must still render if the fetch fails.
    }
  }

  void _navigate(BuildContext context, int index) {
    final lang = widget.languageCode;
    switch (index) {
      case 0:
        context.go('/my-sick-reports?lang=$lang');
        break;
      case 1:
        context.go('/log-vaccination-step1/$lang');
        break;
      case 2:
        context.go('/farmer-dashboard?lang=$lang');
        break;
      case 3:
        context.go('/vaccine-library/$lang');
        break;
      case 4:
        context.go('/farmer-profile/$lang');
        break;
    }
  }

  Widget _sickReportsIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.assignment_outlined, size: 26),
        if (_unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: badgeRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool homeActive = widget.currentIndex == 2;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) => _navigate(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey.withValues(alpha: 0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _sickReportsIcon(),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.vaccines_outlined, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: homeActive
                    ? brandDarkGreen.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.home_rounded,
                color: homeActive
                    ? brandDarkGreen
                    : textGrey.withValues(alpha: 0.6),
                size: 26,
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined, size: 26),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 26),
            label: '',
          ),
        ],
      ),
    );
  }
}