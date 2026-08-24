import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationHeaderButton extends StatefulWidget {
  final String languageCode;
  final Color color;

  const NotificationHeaderButton({
    super.key,
    required this.languageCode,
    required this.color,
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
    await context.push('/notifications/${widget.languageCode}');
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
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFA80000),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
