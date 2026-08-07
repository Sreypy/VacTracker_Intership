import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/reminder_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/config/api_config.dart';

class NotificationScreen extends StatefulWidget {
  final String languageCode; // 'en' or 'km'

  const NotificationScreen({super.key, required this.languageCode});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = false;
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

  static const Map<String, Map<String, String>> _localizedValues = {
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reminderService = ReminderService();
      final reminders = await reminderService.fetchMyReminders();
      final notifications = _buildNotificationModels(reminders);

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildNotificationModels(List<dynamic> reminders) {
    final notifications = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final reminder in reminders) {
      final scheduledDate = reminder['scheduled_date'] != null
          ? DateTime.tryParse(reminder['scheduled_date'].toString())
          : null;

      if (scheduledDate == null) {
        continue;
      }

      final vaccination = reminder['vaccination'];
      final vaccinationMap = vaccination is Map
          ? vaccination
          : <String, dynamic>{};
      final flock = vaccinationMap['flock'];
      final flockMap = flock is Map ? flock : <String, dynamic>{};
      final vaccine = vaccinationMap['vaccine'];
      final vaccineMap = vaccine is Map ? vaccine : <String, dynamic>{};

      final flockName =
          flockMap['batch_name']?.toString() ??
          reminder['flock_name']?.toString() ??
          'Unknown Flock';
      final vaccineName =
          (widget.languageCode == 'km'
              ? vaccineMap['name_km']?.toString()
              : vaccineMap['name_en']?.toString()) ??
          reminder['vaccine_name']?.toString() ??
          'Unknown Vaccine';
      final flockId = flockMap['flock_id'] ?? reminder['flock_id'];
      final status = reminder['status']?.toString() ?? 'pending';
      final daysUntil = scheduledDate.difference(now).inDays;

      // Only show notifications for overdue vaccines or vaccines due within 7 days
      if ((status == 'sent' || status == 'pending') && (daysUntil < 0 || daysUntil <= 7)) {
        notifications.add({
          'type': daysUntil < 0 ? 'overdue' : 'upcoming',
          'title':
              reminder['title']?.toString() ??
              (daysUntil < 0
                  ? _getText('vaccination_overdue')
                  : _getText('vaccination_due')),
          'subtitle':
              reminder['message']?.toString() ?? '$vaccineName - $flockName',
          'days': daysUntil < 0 ? daysUntil.abs() : daysUntil,
          'due_date': scheduledDate,
          'flock_id': flockId,
          'vaccine_id': vaccineMap['vaccine_id'] ?? reminder['vaccine_id'],
          'vaccine_name': vaccineName,
          'flock_name': flockName,
          'icon': daysUntil < 0
              ? Icons.warning_rounded
              : Icons.schedule_rounded,
          'color': daysUntil < 0 ? statusRed : statusYellow,
          'bg_color': daysUntil < 0 ? statusRedBg : statusYellowBg,
        });
      }
    }

    notifications.sort((a, b) {
      if (a['type'] == 'overdue' && b['type'] != 'overdue') return -1;
      if (a['type'] != 'overdue' && b['type'] == 'overdue') return 1;
      return (a['days'] as int).compareTo(b['days'] as int);
    });

    return notifications;
  }

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _markVaccinationAsTaken(int? vaccinationId) async {
    if (vaccinationId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again.'),
            backgroundColor: Color(0xFFA80000),
          ),
        );
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/vaccinations/$vaccinationId');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'completed',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination marked as taken!'),
            backgroundColor: Color(0xFF034418),
          ),
        );
        // Reload notifications to update the list
        await _loadNotifications();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vaccination status.'),
            backgroundColor: Color(0xFFA80000),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating vaccination status.'),
          backgroundColor: Color(0xFFA80000),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: brandDarkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_notifications.length} notifications',
                        style: const TextStyle(
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
            style: const TextStyle(color: textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final isOverdue = type == 'overdue';
    final vaccineName =
        notification['vaccine_name'] as String? ?? 'Unknown Vaccine';
    final flockName = notification['flock_name'] as String? ?? 'Unknown Flock';
    final vaccinationId = notification['vaccine_id'];

    return InkWell(
      onTap: () {
        final flockId = notification['flock_id'];

        if (flockId != null) {
          context.push('/flock-detail/$flockId/${widget.languageCode}');
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
                            notification['title']?.toString() ??
                                (isOverdue
                                    ? 'Take Action Now'
                                    : 'Upcoming Vaccination'),
                            style: TextStyle(
                              color: notification['color'] as Color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification['subtitle']?.toString() ??
                                (isOverdue
                                    ? 'Vaccination is overdue'
                                    : 'Vaccination due soon'),
                            style: const TextStyle(
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
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: brandDarkGreen,
                          ),
                          SizedBox(width: 8),
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
                            child: const Icon(
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
                                const Text(
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
                            child: const Icon(
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
                                const Text(
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
                                ? _formatDate(
                                    notification['due_date'] as DateTime?,
                                  )
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
                if (vaccinationId != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _markVaccinationAsTaken(vaccinationId),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Mark as Taken',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
