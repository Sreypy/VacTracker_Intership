import 'package:flutter/material.dart';
import 'package:frontend/services/reminder_service.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatefulWidget {
  final String languageCode; // 'en' or 'km'

  const NotificationScreen({
    super.key,
    required this.languageCode,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ReminderService _reminderService = ReminderService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  static const Color statusYellow = Color(0xFFB78209);
  static const Color statusYellowBg = Color(0xFFFFF7E5);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusRedBg = Color(0xFFFDE8E8);

  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'app_bar_title': 'Notifications',
      'subtitle': 'Stay updated with your flock health',
      'no_notifications': 'No notifications',
      'no_notifications_subtitle': 'You\'re all caught up!',
      'vaccination_due': 'Vaccination Due',
      'vaccination_overdue': 'Vaccination Overdue',
      'days_remaining': 'days remaining',
      'days_overdue': 'days overdue',
      'due_date': 'Due Date',
    },
    'km': {
      'app_bar_title': 'ការជូនដំណឹង',
      'subtitle': 'ទទួលបានព័ត៌មានថ្មីៗអំពីសុខភាពហ្វូងរបស់អ្នក',
      'no_notifications': 'មិនមានការជូនដំណឹង',
      'no_notifications_subtitle': 'អ្នកបានអានទាំងអស់ហើយ!',
      'vaccination_due': 'ការចាក់វ៉ាក់សាំងជិតដល់',
      'vaccination_overdue': 'ការចាក់វ៉ាក់សាំងហួសកំណត់',
      'days_remaining': 'ថ្ងៃនៅសល់',
      'days_overdue': 'ថ្ងៃហួសកំណត់',
      'due_date': 'កាលបរិច្ឆេទដល់កំណត់',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final reminders = await _reminderService.fetchMyReminders();

      final notifications = <Map<String, dynamic>>[];

      for (var r in reminders) {
        final scheduledDate = r['scheduled_date'] != null 
            ? DateTime.tryParse(r['scheduled_date']) 
            : null;
        
        if (scheduledDate != null) {
          final now = DateTime.now();
          final daysUntil = scheduledDate.difference(now).inDays;
          final vaccination = r['vaccination'] ?? {};
          final flock = vaccination['flock'] ?? {};
          final vaccine = vaccination['vaccine'] ?? {};
          
          final flockName = flock['batch_name'] ?? 'Unknown Flock';
          final vaccineName = vaccine['name'] ?? 'Unknown Vaccine';
          final flockId = flock['flock_id'];
          final status = r['status'] ?? 'pending';

          if (status == 'sent' || status == 'pending') {
            notifications.add({
              'type': daysUntil < 0 ? 'overdue' : 'upcoming',
              'title': r['title'] ?? _getText('vaccination_due'),
              'subtitle': r['message'] ?? '$vaccineName - $flockName',
              'days': daysUntil < 0 ? daysUntil.abs() : daysUntil,
              'due_date': scheduledDate,
              'flock_id': flockId,
              'vaccine_name': vaccineName,
              'flock_name': flockName,
              'icon': daysUntil < 0 ? Icons.warning_rounded : Icons.schedule_rounded,
              'color': daysUntil < 0 ? statusRed : statusYellow,
              'bg_color': daysUntil < 0 ? statusRedBg : statusYellowBg,
            });
          }
        }
      }

      notifications.sort((a, b) {
        if (a['type'] == 'overdue' && b['type'] != 'overdue') return -1;
        if (a['type'] != 'overdue' && b['type'] == 'overdue') return 1;
        return (a['days'] as int).compareTo(b['days'] as int);
      });

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: brandDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_outlined,
              color: brandDarkGreen,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('app_bar_title'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getText('subtitle'),
                style: const TextStyle(color: textGrey, fontSize: 15),
              ),
              const SizedBox(height: 20),

              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 24),
              ] else if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFF991B1B)),
                  ),
                ),
                const SizedBox(height: 24),
              ] else if (_notifications.isEmpty) ...[
                _buildEmptyState(),
                const SizedBox(height: 80),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandDarkGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: brandDarkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_notifications.length} notifications',
                        style: TextStyle(
                          color: brandDarkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                for (final notification in _notifications) ...[
                  _buildNotificationCard(notification),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: textGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getText('no_notifications'),
            style: const TextStyle(
              color: textDarkBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('no_notifications_subtitle'),
            style: TextStyle(
              color: textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final isOverdue = type == 'overdue';
    final vaccineName = notification['vaccine_name'] as String? ?? 'Unknown Vaccine';
    final flockName = notification['flock_name'] as String? ?? 'Unknown Flock';

    return InkWell(
      onTap: () {
        final flockId = notification['flock_id'];
        if (flockId != null) {
          context.push('/log-vaccination-step1/${widget.languageCode}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: notification['color'] as Color,
                  width: 5,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: notification['bg_color'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: notification['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOverdue ? 'Take Action Now' : 'Upcoming Vaccination',
                            style: TextStyle(
                              color: notification['color'] as Color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOverdue
                                ? 'Vaccination is overdue'
                                : 'Vaccination due soon',
                            style: TextStyle(
                              color: textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: textGrey.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Main action card - Which flock to vaccinate
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brandDarkGreen.withValues(alpha: 0.08),
                        brandDarkGreen.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: brandDarkGreen.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: brandDarkGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Vaccination For:',
                            style: TextStyle(
                              color: brandDarkGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.vaccines_outlined,
                              color: brandDarkGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vaccine',
                                  style: TextStyle(
                                    color: textGrey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vaccineName,
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.store_mall_directory_outlined,
                              color: brandDarkGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flock',
                                  style: TextStyle(
                                    color: textGrey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  flockName,
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Date and urgency info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification['bg_color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: notification['color'] as Color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            notification['due_date'] != null
                                ? _formatDate(notification['due_date'] as DateTime?)
                                : '',
                            style: TextStyle(
                              color: notification['color'] as Color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_outlined
                                : Icons.timer_outlined,
                            size: 14,
                            color: notification['color'] as Color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? '${notification['days']} ${_getText('days_overdue')}'
                                : '${notification['days']} ${_getText('days_remaining')}',
                            style: TextStyle(
                              color: notification['color'] as Color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}