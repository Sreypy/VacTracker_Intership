import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String languageCode;

  const VetBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.languageCode,
  });

  static const Color brandDarkBlue = Color(0xFF0F3E6D);
  static const Color textGrey = Color(0xFF5A6B82);

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/vet-reports?lang=$languageCode');
        break;
      case 1:
        context.go('/my-farmers/$languageCode');
        break;
      case 2:
        context.go('/vet-dashboard?lang=$languageCode');
        break;
      case 3:
        context.go('/vet-profile/$languageCode');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool homeActive = currentIndex == 2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigate(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 12, 125, 44),
        unselectedItemColor: textGrey.withValues(alpha: 0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_outlined, size: 26),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: homeActive
                    ? const Color.fromARGB(
                        255,
                        9,
                        112,
                        54,
                      ).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.home_rounded,
                color: homeActive
                    ? const Color.fromARGB(255, 11, 120, 47)
                    : textGrey.withValues(alpha: 0.6),
                size: 26,
              ),
            ),
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
