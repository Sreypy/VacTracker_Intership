import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/vet_dashboard_service.dart';

class VetNotificationScreen extends StatefulWidget {
  final String languageCode;

  const VetNotificationScreen({super.key, required this.languageCode});

  @override
  State<VetNotificationScreen> createState() => _VetNotificationScreenState();
}

class _VetNotificationScreenState extends State<VetNotificationScreen> {
  // Design tokens (matching the vet screens)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color primaryGreen = Color(0xFF0D6E28);

  // Status colors: 🟢 connected / 🟠 pending / 🔴 urgent-rejected / 🔵 info
  static const Color urgentRed = Color(0xFFDC2626);
  // static const Color urgentRedBg = Color(0xFFFEF2F2);
  static const Color pendingAmber = Color(0xFFD97706);
  // static const Color pendingAmberBg = Color(0xFFFFFBEB);
  static const Color infoBlue = Color(0xFF2563EB);
  // static const Color infoBlueBg = Color(0xFFEFF6FF);

  final NotificationService _notificationService = NotificationService();
  final VetDashboardService _vetDashboardService = VetDashboardService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];
  final Set<int> _respondingConnectionIds = {};

  bool get _isKhmer => widget.languageCode == 'km';

  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'title': 'Notifications',
      'mark_all_read': 'Mark all read',
      'today': 'TODAY',
      'earlier': 'EARLIER',
      'empty': 'No notifications yet',
      'empty_subtitle':
          'Sick reports from your farmers and new connection requests will appear here.',
      'load_error': 'Failed to load notifications.',
      'retry': 'Retry',
      'sick_report_title': 'New Sick Report',
      'connection_request_title': 'New Farmer Request',
      'farmer_disconnected_title': 'Farmer Disconnected',
      'farmer_disconnected_message':
          'A farmer has disconnected from your veterinary service.',
      'chickens_affected': 'chickens affected',
      'one_chicken_affected': '1 chicken affected',
      'accept': 'Accept',
      'reject': 'Reject',
      'pending': 'Pending',
      'connected': 'Connected',
      'rejected': 'Rejected',
      'handled': 'Handled',
      'request_accepted': 'Farmer connected!',
      'request_rejected': 'Request rejected',
      'action_failed': 'Failed to update connection request.',
      'just_now': 'just now',
      'minutes_ago': 'min ago',
      'hours_ago': 'h ago',
      'days_ago': 'd ago',
      'urgent': 'URGENT',
    },
    'km': {
      'title': 'ការជូនដំណឹង',
      'mark_all_read': 'សម្គាល់ទាំងអស់ថាបានអាន',
      'today': 'ថ្ងៃនេះ',
      'earlier': 'មុននេះ',
      'empty': 'មិនមានការជូនដំណឹងទេ',
      'empty_subtitle':
          'របាយការណ៍សត្វឈឺពីកសិកររបស់អ្នក និងសំណើភ្ជាប់ថ្មីនឹងបង្ហាញនៅទីនេះ។',
      'load_error': 'មិនអាចផ្ទុកការជូនដំណឹងបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
      'sick_report_title': 'របាយការណ៍សត្វឈឺថ្មី',
      'connection_request_title': 'សំណើកសិករថ្មី',
      'farmer_disconnected_title': 'កសិករបានផ្តាច់',
      'farmer_disconnected_message': 'កសិករបានផ្តាច់ពីសេវាពេទ្យសត្វរបស់អ្នក។',
      'chickens_affected': 'ក្បាលបានរងផលប៉ះពាល់',
      'one_chicken_affected': '១ ក្បាលបានរងផលប៉ះពាល់',
      'accept': 'ទទួលយក',
      'reject': 'បដិសេធ',
      'pending': 'រង់ចាំ',
      'connected': 'បានភ្ជាប់',
      'rejected': 'បានបដិសេធ',
      'handled': 'បានដោះស្រាយ',
      'request_accepted': 'កសិករត្រូវបានភ្ជាប់ជោគជ័យ!',
      'request_rejected': 'បានបដិសេធសំណើ',
      'action_failed': 'មិនអាចធ្វើបច្ចុប្បន្នភាពសំណើបានទេ។',
      'just_now': 'ទើបតែថ្មីៗនេះ',
      'minutes_ago': 'នាទីមុន',
      'hours_ago': 'ម៉ោងមុន',
      'days_ago': 'ថ្ងៃមុន',
      'urgent': 'បន្ទាន់',
    },
  };

  String _getText(String key) =>
      _texts[widget.languageCode]?[key] ?? _texts['en']![key]!;

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
      final data = await _notificationService.fetchMyNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllAsRead();
    if (!mounted) return;
    await _loadNotifications();
  }

  /// Opens the related sick report using the existing vet report detail
  /// screen (reuse of the existing functionality – no new report system).
  Future<void> _openSickReport(Map<String, dynamic> notification) async {
    final notificationId =
        (notification['notification_id'] as num?)?.toInt() ?? 0;
    final reportId = notification['referenceId']?.toString();

    if (notification['is_read'] != true) {
      await _notificationService.markAsRead(notificationId);
    }
    if (!mounted) return;
    if (reportId == null || reportId == 'null') {
      await _loadNotifications();
      return;
    }
    await context.push('/vet-reports/$reportId?lang=${widget.languageCode}');
    if (mounted) await _loadNotifications();
  }

  /// Accepts or rejects a farmer connection request directly from the
  /// notification. Marks the notification as read/handled afterwards.
  Future<void> _respondToConnection(
    Map<String, dynamic> notification,
    bool accept,
  ) async {
    final connectionId = (notification['referenceId'] as num?)?.toInt();
    final notificationId =
        (notification['notification_id'] as num?)?.toInt() ?? 0;
    if (connectionId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _respondingConnectionIds.add(connectionId));

    try {
      await _vetDashboardService.respondToConnection(connectionId, accept);
      await _notificationService.markAsRead(notificationId);
      if (!mounted) return;
      setState(() => _respondingConnectionIds.remove(connectionId));
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _getText(accept ? 'request_accepted' : 'request_rejected'),
          ),
          backgroundColor: accept ? primaryGreen : urgentRed,
        ),
      );
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      setState(() => _respondingConnectionIds.remove(connectionId));
      messenger.showSnackBar(
        SnackBar(
          content: Text(_getText('action_failed')),
          backgroundColor: urgentRed,
        ),
      );
    }
  }

  String _timeAgo(DateTime created) {
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return _getText('just_now');
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${_getText('minutes_ago')}';
    }
    if (diff.inHours < 24) return '${diff.inHours} ${_getText('hours_ago')}';
    if (diff.inDays < 7) return '${diff.inDays} ${_getText('days_ago')}';
    return '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,

      appBar: AppBar(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        title: Text(
          _getText('title'),
          style: const TextStyle(
            color: textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              _getText('mark_all_read'),
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: _buildBody(),

      // Bottom navigation
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getText('load_error'),
              style: const TextStyle(color: textMuted),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(_getText('retry')),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        color: primaryGreen,
        onRefresh: _loadNotifications,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getText('empty'),
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _getText('empty_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Group into TODAY / EARLIER sections.
    final todayItems = <Map<String, dynamic>>[];
    final earlierItems = <Map<String, dynamic>>[];
    for (final notification in _notifications) {
      final created =
          DateTime.tryParse(notification['created_at']?.toString() ?? '') ??
          DateTime.now();
      if (_isToday(created)) {
        todayItems.add(notification);
      } else {
        earlierItems.add(notification);
      }
    }

    final children = <Widget>[];
    if (todayItems.isNotEmpty) {
      children.add(_buildSectionHeader(_getText('today')));
      children.addAll(todayItems.map(_buildNotificationCard));
    }
    if (earlierItems.isNotEmpty) {
      children.add(_buildSectionHeader(_getText('earlier')));
      children.addAll(earlierItems.map(_buildNotificationCard));
    }

    return RefreshIndicator(
      color: primaryGreen,
      onRefresh: _loadNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: textMuted.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// Builds a single notification card based on its type.
  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type']?.toString();
    final isRead = notification['is_read'] == true;
    if (type == 'sick_report') {
      return _buildSickReportCard(notification, isRead);
    }
    if (type == 'farmer_connection_request') {
      return _buildConnectionRequestCard(notification, isRead);
    }
    if (type == 'farmer_disconnected') {
      return _buildFarmerDisconnectedCard(notification, isRead);
    }
    return _buildGenericCard(notification, isRead);
  }

  /// 🔵 Farmer Disconnected — informational card for the vet.
  Widget _buildFarmerDisconnectedCard(
    Map<String, dynamic> notification,
    bool isRead,
  ) {
    final data = notification['data'] is Map
        ? Map<String, dynamic>.from(notification['data'] as Map)
        : <String, dynamic>{};
    final farmerName = (data['farmer_name'] ?? '').toString();

    final created =
        DateTime.tryParse(notification['created_at']?.toString() ?? '') ??
        DateTime.now();

    return _buildCardShell(
      accentColor: isRead ? textMuted : infoBlue,
      backgroundColor: isRead
          ? surfaceWhite
          : const Color.fromARGB(255, 255, 255, 255),
      isUnread: !isRead,
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🔵', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('farmer_disconnected_title'),
                      style: TextStyle(
                        color: textMain,
                        fontSize: 14,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isKhmer
                          ? '$farmerName បានផ្តាច់ពីសេវាពេទ្យសត្វរបស់អ្នក។'
                          : farmerName.isEmpty
                          ? _getText('farmer_disconnected_message')
                          : '$farmerName has disconnected from your veterinary service.',
                      style: const TextStyle(color: textMain, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _timeAgo(created),
              style: const TextStyle(color: textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// 🐔 New Sick Report — tap opens the existing vet sick report detail.
  Widget _buildSickReportCard(Map<String, dynamic> notification, bool isRead) {
    final data = notification['data'] is Map
        ? Map<String, dynamic>.from(notification['data'] as Map)
        : <String, dynamic>{};
    final farmerName = (data['farmer_name'] ?? notification['message'] ?? '')
        .toString();
    final flockName = (data['flock_name'] ?? '').toString();
    final affectedCount = (data['affected_count'] as num?)?.toInt() ?? 0;

    final created =
        DateTime.tryParse(notification['created_at']?.toString() ?? '') ??
        DateTime.now();

    return _buildCardShell(
      accentColor: isRead ? textMuted : urgentRed,
      backgroundColor: isRead
          ? surfaceWhite
          : const Color.fromARGB(255, 255, 255, 255),
      isUnread: !isRead,
      onTap: () => _openSickReport(notification),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🐔', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getText('sick_report_title'),
                            style: TextStyle(
                              color: textMain,
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgentRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getText('urgent'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isKhmer
                          ? '$farmerName បានរាយការណ៍សត្វឈឺនៅ${flockName.isEmpty ? '' : ' $flockName'}។'
                          : farmerName.isEmpty
                          ? _getText('sick_report_title')
                          : '$farmerName reported sick chickens${flockName.isEmpty ? '.' : ' in $flockName.'}',
                      style: const TextStyle(color: textMain, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  affectedCount <= 0
                      ? ''
                      : affectedCount == 1
                      ? _getText('one_chicken_affected')
                      : '$affectedCount ${_getText('chickens_affected')}',
                  style: const TextStyle(
                    color: urgentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(created),
                style: const TextStyle(color: textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Fallback for unknown/system notification types.
  Widget _buildGenericCard(Map<String, dynamic> notification, bool isRead) {
    final created =
        DateTime.tryParse(notification['created_at']?.toString() ?? '') ??
        DateTime.now();

    return _buildCardShell(
      accentColor: textMuted,
      backgroundColor: surfaceWhite,
      isUnread: !isRead,
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification['title']?.toString() ?? '',
            style: TextStyle(
              color: textMain,
              fontSize: 14,
              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notification['message']?.toString() ?? '',
            style: const TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _timeAgo(created),
              style: const TextStyle(color: textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// 👨‍🌾 New Farmer Request — inline Accept / Reject actions while pending.
  Widget _buildConnectionRequestCard(
    Map<String, dynamic> notification,
    bool isRead,
  ) {
    final data = notification['data'] is Map
        ? Map<String, dynamic>.from(notification['data'] as Map)
        : <String, dynamic>{};
    final farmerName = (data['farmer_name'] ?? notification['message'] ?? '')
        .toString();
    final connectionId =
        (data['connection_id'] as num?)?.toInt() ??
        (notification['referenceId'] as num?)?.toInt();
    final isResponding =
        connectionId != null && _respondingConnectionIds.contains(connectionId);

    final created =
        DateTime.tryParse(notification['created_at']?.toString() ?? '') ??
        DateTime.now();

    return _buildCardShell(
      accentColor: isRead ? infoBlue : pendingAmber,
      backgroundColor: isRead
          ? surfaceWhite
          : const Color.fromARGB(255, 255, 255, 255),
      isUnread: !isRead,
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('👨‍🌾', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('connection_request_title'),
                      style: TextStyle(
                        color: textMain,
                        fontSize: 14,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isKhmer
                          ? '$farmerName ចង់ភ្ជាប់ជាមួយអ្នក។'
                          : '$farmerName wants to connect with you.',
                      style: const TextStyle(color: textMain, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isResponding)
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryGreen,
                  ),
                ),
              ],
            )
          else if (!isRead)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: connectionId == null
                        ? null
                        : () => _respondToConnection(notification, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: urgentRed,
                      side: const BorderSide(color: urgentRed),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getText('reject'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: connectionId == null
                        ? null
                        : () => _respondToConnection(notification, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getText('accept'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: _buildStatusChip(
                label: _getText('handled'),
                color: infoBlue,
                background: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ).withValues(alpha: 0.05),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _timeAgo(created),
              style: const TextStyle(color: textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShell({
    required Color accentColor,
    required Color backgroundColor,
    required bool isUnread,
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? accentColor.withValues(alpha: 0.35) : borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(left: BorderSide(color: accentColor, width: 4)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required bool isSelected,
  }) {
    final color = isSelected ? primaryGreen : textMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (GoRouterState.of(context).uri.path != route) {
            context.go(route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 24, color: color),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                route: '/vet-dashboard?${widget.languageCode}',
                isSelected: false,
              ),

              _buildNavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                route: '/vet-reports?${widget.languageCode}',
                isSelected: false,
              ),

              _buildNavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                route: '/my-farmers/${widget.languageCode}',
                isSelected: false,
              ),

              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                route: '/vet-profile/${widget.languageCode}',
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
