import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/vaccination_schedule_service.dart';
import 'package:frontend/services/vaccination_service.dart';
import 'package:go_router/go_router.dart';

class NotificationHeaderButton extends StatefulWidget {
  final String languageCode;
  final Color color;

  /// Shows the unread count as a numeric badge (e.g. 🔔 2) instead of only
  /// a small dot. Used on the vet dashboard.
  final bool showCount;

  /// Route of the notification screen to open. Farmers use the default
  /// '/notifications/:lang', vets use '/vet-notifications/:lang'.
  final String notificationsRoute;

  const NotificationHeaderButton({
    super.key,
    required this.languageCode,
    required this.color,
    this.showCount = false,
    this.notificationsRoute = '/notifications',
  });

  static Future<void> refreshDueTodayCount() =>
      _NotificationHeaderButtonState.refreshDueTodayCount();

  @override
  State<NotificationHeaderButton> createState() =>
      _NotificationHeaderButtonState();
}

class _NotificationHeaderButtonState extends State<NotificationHeaderButton> {
  static final ValueNotifier<int> _dueTodayCountNotifier = ValueNotifier(0);
  int _unreadCount = 0;
  int _dueTodayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _loadDueTodayCount();
    _dueTodayCountNotifier.addListener(_applySharedDueTodayCount);
  }

  @override
  void dispose() {
    _dueTodayCountNotifier.removeListener(_applySharedDueTodayCount);
    super.dispose();
  }

  void _applySharedDueTodayCount() {
    if (mounted) setState(() => _dueTodayCount = _dueTodayCountNotifier.value);
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService().fetchUnreadCount();
    if (!mounted) return;
    setState(() => _unreadCount = count);
  }

  Future<void> _loadDueTodayCount() async {
    await NotificationHeaderButton.refreshDueTodayCount();
  }

  static Future<void> refreshDueTodayCount() async {
    try {
      final vaccinations = await VaccinationService().fetchAllVaccinations();
      final count = VaccinationScheduleSummary.fromRecords(
        vaccinations,
      ).dueTodayCount;
      _dueTodayCountNotifier.value = count;
    } catch (_) {
      // The notification icon remains usable if the optional badge fetch fails.
    }
  }

  Future<void> _openNotifications() async {
    await context.push('${widget.notificationsRoute}/${widget.languageCode}');
    if (!mounted) return;
    _loadUnreadCount();
    if (widget.notificationsRoute == '/notifications') {
      _loadDueTodayCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFarmerRoute = widget.notificationsRoute == '/notifications';
    final badgeCount = isFarmerRoute ? _dueTodayCount : _unreadCount;
    return IconButton(
      tooltip: 'Notifications',
      onPressed: _openNotifications,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            color: widget.color,
            size: 26,
          ),
          if (badgeCount > 0)
            Positioned(
              right: -10,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA80000),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
