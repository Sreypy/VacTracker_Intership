import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';
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

  @override
  State<NotificationHeaderButton> createState() =>
      _NotificationHeaderButtonState();
}

class _NotificationHeaderButtonState extends State<NotificationHeaderButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService().fetchUnreadCount();
    if (!mounted) return;
    setState(() => _unreadCount = count);
  }

  Future<void> _openNotifications() async {
    await context.push('${widget.notificationsRoute}/${widget.languageCode}');
    if (mounted) _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
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
          if (_unreadCount > 0)
            Positioned(
              right: widget.showCount ? -10 : -2,
              top: widget.showCount ? -4 : -2,
              child: Container(
                padding: widget.showCount
                    ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1)
                    : EdgeInsets.zero,
                constraints: widget.showCount
                    ? const BoxConstraints(minWidth: 16)
                    : const BoxConstraints(minWidth: 6, minHeight: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA80000),
                  borderRadius: BorderRadius.circular(10),
                  shape: widget.showCount
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: widget.showCount
                    ? Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
