import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/models/sick_report.dart';
import 'package:frontend/services/sick_report_service.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:go_router/go_router.dart';

class MySickReportsScreen extends StatefulWidget {
  final String languageCode;
  const MySickReportsScreen({super.key, required this.languageCode});

  @override
  State<MySickReportsScreen> createState() => _MySickReportsScreenState();
}

class _MySickReportsScreenState extends State<MySickReportsScreen> {
  String _profileName = '';
  String _profileImageUrl = '';

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);

  final _service = SickReportService();
  bool _loading = true;
  String? _error;
  List<SickReport> _reports = const [];

  bool get _km => widget.languageCode == 'km';
  String get _waiting => _km ? 'កំពុងរង់ចាំពេទ្យសត្វ' : 'Waiting for Vet';
  String get _responded => _km ? 'ពេទ្យសត្វបានឆ្លើយតប' : 'Vet Responded';
  String get _resolved => _km ? 'បានដោះស្រាយ' : 'Resolved';

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
    final bool hasImage = _profileImageUrl.isNotEmpty;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: brandDarkGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              _profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: brandDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await _service.fetchMyReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _km
              ? 'មិនអាចផ្ទុករបាយការណ៍បានទេ។'
              : 'Could not load sick reports.';
          _loading = false;
        });
      }
    }
  }

  String _reportType(String type) {
    final values = {
      'disease': _km ? 'របាយការណ៍ជំងឺ' : 'Disease Report',
      'injury': _km ? 'របាយការណ៍របួស' : 'Injury Report',
      'death': _km ? 'របាយការណ៍ស្លាប់' : 'Death Report',
      'other': _km ? 'របាយការណ៍ផ្សេងទៀត' : 'Other Report',
    };
    return values[type] ?? type;
  }

  ({String label, Color color, Color bgColor}) _status(SickReport report) {
    if (report.status == 'resolved') {
      return (
        label: _resolved,
        color: const Color(0xFF1D4ED8),
        bgColor: const Color(0xFFEFF6FF),
      );
    }
    if (report.hasVetResponse || report.status == 'reviewed') {
      return (
        label: _responded,
        color: const Color(0xFF15803D),
        bgColor: const Color(0xFFF0FDF4),
      );
    }
    return (
      label: _waiting,
      color: const Color(0xFFB45309),
      bgColor: const Color(0xFFFFFBEB),
    );
  }

  String _date(DateTime date) =>
      '${date.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
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
    body: _loading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF034418)),
          )
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(_km ? 'ព្យាយាមម្ដងទៀត' : 'Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF034418),
                      side: const BorderSide(color: Color(0xFF034418)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            color: const Color(0xFF034418),
            onRefresh: _load,
            child: _reports.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.health_and_safety_outlined,
                            size: 56,
                            color: Color(0xFF034418),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _km
                              ? 'មិនទាន់មានរបាយការណ៍សត្វឈឺទេ។'
                              : 'No sick reports yet.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    // ignore: unnecessary_underscores
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, index) => _card(_reports[index]),
                  ),
          ),
    bottomNavigationBar: FarmerBottomNavigation(
      currentIndex: 0,
      languageCode: widget.languageCode,
    ),
  );

  Widget _card(SickReport report) {
    final status = _status(report);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _reportType(report.reportType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                report.flockName?.trim().isNotEmpty == true
                    ? report.flockName!
                    : (_km ? 'ហ្វូងមិនស្គាល់' : 'Unknown flock'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.pets_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                _km
                    ? '${report.affectedCount} ក្បាលរងផលប៉ះពាល់'
                    : '${report.affectedCount} birds affected',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                _date(report.reportDate),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ],
          ),
          if (report.hasVetResponse) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/my-sick-reports/${report.reportId}?lang=${widget.languageCode}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034418),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _km ? 'មើលការឆ្លើយតប' : 'View Response',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
