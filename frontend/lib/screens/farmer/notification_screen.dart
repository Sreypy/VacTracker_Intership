import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/services/vaccination_service.dart';
import 'package:frontend/services/vaccination_schedule_service.dart';

class NotificationScreen extends StatefulWidget {
  final String languageCode;

  const NotificationScreen({super.key, required this.languageCode});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  // --- Updated Color Palette (matches provided image and common app style) ---
  static const Color colorBackground = Color(0xFFF9FAFB);
  static const Color colorText = Color(0xFF111827);
  static const Color colorMuted = Color(0xFF6B7280);
  static const Color colorApp = Color(0xFF228B22); // Forest Green
  static const Color colorSurface = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);

  // Status colors
  static const Color colorOverdue = Color(0xFFDC2626); // Alert Red
  static const Color colorDueSoon = Color(0xFFF59E0B); // Amber Yellow
  static const Color colorScheduled = Color(0xFF10B981); // Green

  static const Color colorLightRed = Color(0xFFFEE2E2);
  static const Color colorLightAmber = Color(0xFFFEF3C7);
  static const Color colorLightGreen = Color(0xFFD1FAE5);

  bool _isLoading = true;
  String? _errorMessage;
  List<_NotificationItem> _notifications = [];
  int _overdueCount = 0;
  int _dueSoonCount = 0;
  String _profileName = 'User';
  String _profileImageUrl = '';

  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'title': 'Notifications',
      'subtitle': 'Your vaccination reminders',
      'action_today_card_title': 'Today\'s Action',
      'due_soon': 'Due Soon',
      'due_today': 'Due Today',
      'overdue': 'Overdue',
      'action_needed_label': 'ACTION NEEDED',
      'upcoming_label': 'UPCOMING',
      'scheduled_label': 'SCHEDULED',
      'days_remaining': 'days remaining',
      'day_remaining': 'day remaining',
      'days_overdue': 'days overdue',
      'day_overdue': 'day overdue',
      'vaccinate_now_btn': 'Vaccinate Now',
      'view_flock_btn': 'View Flock',
      'no_notifications': 'No vaccination reminders',
      'no_notifications_subtitle': 'Your flock is up to date.',
      'load_error': 'We could not load your notifications.',
      'retry': 'Retry',
      'unknown_flock': 'Unknown flock',
      'unknown_vaccine': 'Unknown vaccine',
      'overdue_title': 'Vaccination overdue',
      'due_soon_title': 'Vaccination due soon',
      'scheduled_title': 'Vaccination scheduled',
      'action_required_header': 'Action Required',
      'view_details_btn': 'View Details',
      'vet_response_label': 'VET RESPONSE',
      'vet_response_title': 'Veterinarian Response',
      'view_report_btn': 'View Report',
    },
    'km': {
      'title': 'ការជូនដំណឹង',
      'subtitle': 'ការរំលឹកចាក់វ៉ាក់សាំងរបស់អ្នក',
      'action_today_card_title': 'សកម្មភាពថ្ងៃនេះ',
      'due_soon': 'ជិតដល់កំណត់',
      'due_today': 'ដល់កំណត់ថ្ងៃនេះ',
      'overdue': 'ហួសកំណត់',
      'action_needed_label': 'ត្រូវការសកម្មភាព',
      'upcoming_label': 'ខាងមុខ',
      'scheduled_label': 'បានកំណត់',
      'days_remaining': 'ថ្ងៃនៅសល់',
      'day_remaining': 'ថ្ងៃនៅសល់',
      'days_overdue': 'ថ្ងៃហួសកំណត់',
      'day_overdue': 'ថ្ងៃហួសកំណត់',
      'vaccinate_now_btn': 'ចាក់វ៉ាក់សាំងឥឡូវនេះ',
      'view_flock_btn': 'មើលហ្វូង',
      'no_notifications': 'មិនមានការរំលឹកចាក់វ៉ាក់សាំង',
      'no_notifications_subtitle': 'ហ្វូងរបស់អ្នកមានបច្ចុប្បន្នភាពល្អ។',
      'load_error': 'មិនអាចផ្ទុកការជូនដំណឹងបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
      'unknown_flock': 'មិនស្គាល់ហ្វូង',
      'unknown_vaccine': 'មិនស្គាល់វ៉ាក់សាំង',
      'overdue_title': 'ការចាក់វ៉ាក់សាំងហួសកំណត់',
      'due_soon_title': 'ការចាក់វ៉ាក់សាំងជិតដល់កំណត់',
      'scheduled_title': 'ការចាក់វ៉ាក់សាំងត្រូវបានកំណត់ពេល',
      'action_required_header': 'ត្រូវការសកម្មភាព',
      'view_details_btn': 'មើលព័ត៌មានលម្អិត',
      'vet_response_label': 'ការឆ្លើយតបពីពេទ្យសត្វ',
      'vet_response_title': 'ការឆ្លើយតបពីពេទ្យសត្វ',
      'view_report_btn': 'មើលរបាយការណ៍',
    },
  };

  String _getText(String key) =>
      _texts[widget.languageCode]?[key] ?? _texts['en']![key]!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _loadNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadNotifications();
    }
  }

  Future<void> _loadProfile() async {
    final storedName = await StorageService.getName();
    final storedImageUrl = await StorageService.getProfileImageUrl();
    if (!mounted) return;
    setState(() {
      if (storedName?.trim().isNotEmpty == true) {
        _profileName = storedName!.trim();
      }
      if (storedImageUrl?.trim().isNotEmpty == true) {
        _profileImageUrl = storedImageUrl!.trim();
      }
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200 || !mounted) return;
      final profile = jsonDecode(response.body) as Map<String, dynamic>;
      final name = (profile['name'] ?? '').toString().trim();
      final imageUrl =
          (profile['profile_image_url'] ??
                  profile['avatar_url'] ??
                  profile['profile_image'] ??
                  profile['image_url'] ??
                  profile['photo_url'] ??
                  '')
              .toString()
              .trim();
      setState(() {
        if (name.isNotEmpty) _profileName = name;
        if (imageUrl.isNotEmpty) _profileImageUrl = imageUrl;
      });
      await StorageService.saveUser(profile);
    } catch (_) {
      // Stored profile data or initials remain available as a fallback.
    }
  }

  Widget _buildProfileAvatar() {
    final initial = _profileName.trim().isNotEmpty
        ? _profileName.trim()[0].toUpperCase()
        : 'U';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorMuted.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _profileImageUrl.isNotEmpty
          ? Image.network(
              _profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: colorApp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: colorApp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      // Fetch both vaccination reminders and vet response notifications in parallel
      final results = await Future.wait([
        VaccinationService().fetchAllVaccinations(),
        NotificationService().fetchMyNotifications(),
      ]);

      final vaccinations = results[0];
      final notifications = results[1];

      final items = <_NotificationItem>[];
      final schedule = VaccinationScheduleSummary.fromRecords(vaccinations);

      // Build vaccination notifications from the canonical vaccination data.
      for (final vaccination in vaccinations) {
        if (VaccinationScheduleService.dueDateFor(vaccination) == null ||
            VaccinationScheduleService.isCompleted(vaccination)) {
          continue;
        }
        final item = _NotificationItem.fromVaccination(
          vaccination,
          widget.languageCode,
        );
        if (item != null) items.add(item);
      }

      // Add server notifications such as veterinarian responses.
      for (final notification in notifications) {
        if (notification is! Map) continue;
        final type = notification['type']?.toString();
        _NotificationItem? item;
        if (type == 'vet_response') {
          item = _NotificationItem.fromVetResponse(
            notification,
            widget.languageCode,
          );
        }
        if (item == null) continue;

        items.add(item);
      }

      items.sort((first, second) {
        if (first.isVetResponse != second.isVetResponse) {
          return first.isVetResponse ? -1 : 1;
        }
        if (first.isOverdue != second.isOverdue) {
          return first.isOverdue ? -1 : 1;
        }
        return first.dueDate.compareTo(second.dueDate);
      });

      // Calculate summaries
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _overdueCount = schedule.overdueCount;
        _dueSoonCount = schedule.dueSoonCount;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getText('load_error');
        _isLoading = false;
      });
    }
  }

  Future<void> _openNotification(_NotificationItem item) async {
    if (item.isVetResponse) {
      if (item.notificationId != null) {
        await NotificationService().markAsRead(item.notificationId!);
      }
      if (!mounted) return;

      debugPrint(
        'reportId: ${item.reportId}, languageCode: ${widget.languageCode}',
      );

      if (item.reportId != null) {
        context.push(
          '/my-sick-reports/${item.reportId}?lang=${widget.languageCode}',
        );
      } else {
        debugPrint('reportId is null — navigation skipped');
      }
      return;
    }
    if (item.flockId == null) return;
    // Mark an overdue-vaccination notification as read when the farmer taps it.
    if (item.notificationId != null) {
      await NotificationService().markAsRead(item.notificationId!);
      if (!mounted) return;
    }
    if (item.isOverdue || item.isDueToday) {
      if (item.vaccineId == null) return;
      final result = await context.push<bool>(
        '/log-vaccination-step2/${widget.languageCode}'
        '?flockId=${item.flockId}&batchTitle=${Uri.encodeComponent(item.flockName)}'
        '&vaccineId=${item.vaccineId}',
      );
      if (result == true && mounted) {
        await _loadNotifications();
      }
      return;
    }
    await context.push('/flock-detail/${item.flockId}/${widget.languageCode}');
    if (mounted) {
      _loadNotifications();
    }
  }

  // --- Simplified Date Format ---
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_getEnMonthAbbreviation(date.month)} ${date.year}';

  String _getEnMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: const Text(
          'VacTracker',
          style: TextStyle(
            color: brandDarkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationHeaderButton(
            languageCode: widget.languageCode,
            color: brandDarkGreen,
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () =>
                context.push('/farmer-profile/${widget.languageCode}'),
            icon: _buildProfileAvatar(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: colorApp,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                _getText('title'),
                style: const TextStyle(
                  color: colorText,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Text(
                _getText('subtitle'),
                style: const TextStyle(color: colorMuted, fontSize: 16),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: colorApp),
                    )
                  : _errorMessage != null
                  ? _buildErrorState()
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 28),
                        _buildHeaderWithFilter(),
                        const SizedBox(height: 16),
                        if (_notifications.isEmpty)
                          _buildEmptyState()
                        else
                          ..._notifications.map(_buildNotificationCard),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 0,
        languageCode: widget.languageCode,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.cloud_off_outlined, size: 56, color: colorMuted),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: colorText),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh, color: colorApp),
            label: Text(
              _getText('retry'),
              style: const TextStyle(color: colorApp),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: colorApp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.notifications_none, size: 64, color: colorMuted),
          const SizedBox(height: 14),
          Text(
            _getText('no_notifications'),
            style: const TextStyle(
              color: colorText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('no_notifications_subtitle'),
            style: const TextStyle(color: colorMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- Summary Card Widget ---
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: colorLightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: colorApp,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _getText('action_today_card_title'),
                style: const TextStyle(
                  color: colorText,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(colorOverdue, _getText('overdue'), _overdueCount),
          const SizedBox(height: 14),
          _summaryRow(colorDueSoon, _getText('due_soon'), _dueSoonCount),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity),
        ],
      ),
    );
  }

  Widget _summaryRow(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: colorMuted, fontSize: 15)),
        const Spacer(),
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  // --- Header with Filter Button ---
  Widget _buildHeaderWithFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getText('action_required_header'),
          style: const TextStyle(
            color: colorText,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        TextButton.icon(
          onPressed: () {}, // Show filter options
          icon: const Text('Filter'), // Key is same for en/km in design
          label: const Icon(Icons.filter_list_rounded, size: 18),
          style: TextButton.styleFrom(
            foregroundColor: colorApp,
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  // --- Refactored Notification Card ---
  Widget _buildNotificationCard(_NotificationItem item) {
    // Styling constants
    final colorMain = item.mainColor;
    final colorLight = item.lightColor;
    final iconData = item.cardIconData;
    final countText = item.timeCountText(_getText);

    final actionText = item.actionButtonText(_getText);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: item.actionButtonColor,
      foregroundColor: item.actionButtonForegroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      side: item.isDueSoon
          ? const BorderSide(color: colorScheduled)
          : null, // Special casing outline button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colorMain, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: colorMain, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.labelPrefix(_getText),
                            style: TextStyle(
                              color: colorMain,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' • $countText',
                            style: TextStyle(color: colorMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.cardTitle(_getText),
                        style: const TextStyle(
                          color: colorText,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (item.isVetResponse)
              _detailRow(Icons.medical_services_outlined, item.vetMessage ?? '')
            else ...[
              _detailRow(Icons.home_work_outlined, item.flockName),
              const SizedBox(height: 10),
              _detailRow(Icons.vaccines_outlined, item.vaccineName),
              const SizedBox(height: 10),
              _detailRow(
                Icons.calendar_today_outlined,
                'Due ${_formatDate(item.dueDate)}',
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: item.isVetResponse
                    ? () => _openNotification(item)
                    : item.flockId == null
                    ? null
                    : () => _openNotification(item),
                style: buttonStyle,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row for card details (icon, text)
  Widget _detailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationItem {
  final String flockName;
  final String vaccineName;
  final DateTime dueDate;
  final int? flockId;
  final int? vaccineId;
  final int days;
  final bool isVetResponse;
  final String? vetMessage;
  final int? notificationId;
  final int? reportId;

  const _NotificationItem({
    required this.flockName,
    required this.vaccineName,
    required this.dueDate,
    required this.flockId,
    required this.vaccineId,
    required this.days,
    this.isVetResponse = false,
    this.vetMessage,
    this.notificationId,
    this.reportId,
  });

  bool get isOverdue => days < 0;
  bool get isDueToday => days == 0;
  // Define "due soon" as within 7 days, excluding today.
  bool get isDueSoon => days > 0 && days <= 7;
  bool get isScheduled => days > 7;

  // Visual Styling Properties

  Color get mainColor {
    if (isVetResponse) return _NotificationScreenState.colorApp;
    if (isOverdue) return _NotificationScreenState.colorOverdue;
    if (isDueToday || isDueSoon) return _NotificationScreenState.colorDueSoon;
    return _NotificationScreenState.colorScheduled;
  }

  Color get lightColor {
    if (isVetResponse) return _NotificationScreenState.colorLightGreen;
    if (isOverdue) return _NotificationScreenState.colorLightRed;
    if (isDueToday || isDueSoon)
      // ignore: curly_braces_in_flow_control_structures
      return _NotificationScreenState.colorLightAmber;
    return _NotificationScreenState.colorLightGreen;
  }

  IconData get cardIconData {
    if (isVetResponse) return Icons.medical_services_outlined;
    if (isOverdue) return Icons.report_problem_outlined;
    return Icons.schedule_rounded; // Works well for upcoming too
  }

  // Label specific to design requirements
  String labelPrefix(String Function(String) text) {
    if (isVetResponse) return text('vet_response_label');
    if (isOverdue) return text('action_needed_label');
    if (isDueToday || isDueSoon) return text('upcoming_label');
    return text('scheduled_label');
  }

  // Card text relative to design
  String timeCountText(String Function(String) text) {
    if (isVetResponse) return '';
    if (isOverdue) {
      final absDays = days.abs();
      return '$absDays ${absDays == 1 ? text('day_overdue') : text('days_overdue')}';
    }
    if (isDueToday) return text('due_today');
    // For both due soon and later scheduled
    return '$days ${days == 1 ? text('day_remaining') : text('days_remaining')}';
  }

  // Specific titles used in design
  String cardTitle(String Function(String) text) {
    if (isVetResponse) return text('vet_response_title');
    if (isOverdue) return text('overdue_title');
    if (isDueToday || isDueSoon) return text('due_soon_title');
    return text('scheduled_title');
  }

  // Action Button Configuration
  String actionButtonText(String Function(String) text) {
    if (isVetResponse) return text('view_report_btn');
    if (isOverdue || isDueToday) return text('vaccinate_now_btn');
    if (isDueSoon) return text('view_flock_btn');
    return text('view_details_btn');
  }

  Color get actionButtonColor {
    if (isVetResponse) return _NotificationScreenState.colorApp;
    if (isOverdue || isDueToday) return _NotificationScreenState.colorOverdue;
    if (isDueSoon) return Colors.transparent; // Outline button style
    return _NotificationScreenState.colorMuted.withValues(
      alpha: 0.1,
    ); // Greyscale action
  }

  Color get actionButtonForegroundColor {
    if (isVetResponse) return Colors.white;
    if (isDueSoon) return _NotificationScreenState.colorScheduled;
    if (isOverdue || isDueToday) return Colors.white;
    return _NotificationScreenState.colorText;
  }

  // Mapper for vet response notifications
  static _NotificationItem? fromVetResponse(dynamic raw, String languageCode) {
    if (raw is! Map) return null;
    final notification = Map<String, dynamic>.from(raw);
    final createdRaw = notification['created_at']?.toString();
    final createdDate = DateTime.tryParse(createdRaw ?? '');
    if (createdDate == null) return null;

    final today = DateTime.now();
    final createdDay = DateTime(
      createdDate.year,
      createdDate.month,
      createdDate.day,
    );
    final todayDay = DateTime(today.year, today.month, today.day);

    return _NotificationItem(
      flockName: 'Veterinarian',
      vaccineName: 'Sick Report',
      dueDate: createdDay,
      flockId: null,
      vaccineId: null,
      days: createdDay.difference(todayDay).inDays,
      isVetResponse: true,
      vetMessage: notification['message']?.toString() ?? '',
      notificationId: _asInt(notification['notification_id']),
      reportId: _asInt(notification['referenceId']),
    );
  }

  // Mapper for overdue vaccination notifications (type = vaccination_overdue)
  static _NotificationItem? fromVaccination(dynamic raw, String languageCode) {
    if (raw is! Map) return null;
    final vaccination = Map<String, dynamic>.from(raw);
    final dueDate = VaccinationScheduleService.dueDateFor(vaccination);
    if (dueDate == null) return null;

    final flock = vaccinationMap(vaccination['flock']);
    final vaccine = vaccinationMap(vaccination['vaccine']);
    final today = VaccinationScheduleService.calendarDate(DateTime.now());
    final dueDay = VaccinationScheduleService.calendarDate(dueDate);

    return _NotificationItem(
      flockName: (flock['batch_name'] ?? 'Unknown flock').toString(),
      vaccineName:
          (languageCode == 'km'
                  ? vaccine['name_km'] ??
                        vaccine['name_en'] ??
                        'Unknown vaccine'
                  : vaccine['name_en'] ??
                        vaccine['name_km'] ??
                        'Unknown vaccine')
              .toString(),
      dueDate: dueDay,
      flockId: VaccinationScheduleService.flockIdFor(vaccination),
      vaccineId: _asInt(vaccine['vaccine_id'] ?? vaccination['vaccine_id']),
      days: dueDay.difference(today).inDays,
    );
  }

  static Map<String, dynamic> vaccinationMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int? _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
}
