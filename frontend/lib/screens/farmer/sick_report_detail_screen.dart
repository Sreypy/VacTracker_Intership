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

class FarmerSickReportDetailScreen extends StatefulWidget {
  final int reportId;
  final String languageCode;
  const FarmerSickReportDetailScreen({
    super.key,
    required this.reportId,
    required this.languageCode,
  });

  @override
  State<FarmerSickReportDetailScreen> createState() =>
      _FarmerSickReportDetailScreenState();
}

class _FarmerSickReportDetailScreenState
    extends State<FarmerSickReportDetailScreen> {
  String _profileName = '';
  String _profileImageUrl = '';

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);

  final _service = SickReportService();
  SickReport? _report;
  bool _loading = true;
  String? _error;

  bool get _km => widget.languageCode == 'km';

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
      final report = await _service.fetchReport(widget.reportId);
      if (mounted) {
        setState(() {
          _report = report;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _km
              ? 'មិនអាចផ្ទុករបាយការណ៍បានទេ។'
              : 'Could not load sick report.';
          _loading = false;
        });
      }
    }
  }

  String _date(DateTime d) =>
      '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';

  String _dateTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '${_date(d)}, $hour:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _type(String type) =>
      {
        'disease': _km ? 'ជំងឺ' : 'Disease',
        'injury': _km ? 'របួស' : 'Injury',
        'death': _km ? 'ស្លាប់' : 'Death',
        'other': _km ? 'ផ្សេងទៀត' : 'Other',
      }[type] ??
      type;

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
            child: OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_km ? 'ព្យាយាមម្ដងទៀត' : 'Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF034418),
                side: const BorderSide(color: Color(0xFF034418)),
              ),
            ),
          )
        : RefreshIndicator(
            color: const Color(0xFF034418),
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [_content(_report!)],
            ),
          ),
    bottomNavigationBar: FarmerBottomNavigation(
      currentIndex: 0,
      languageCode: widget.languageCode,
    ),
  );

  Future<void> _markResolved() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_km ? 'បញ្ជាក់' : 'Confirm'),
        content: Text(
          _km
              ? 'តើអ្នកប្រាកដថាបញ្ហាត្រូវបានដោះស្រាយហើយឬទេ?'
              : 'Are you sure the problem has been resolved?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_km ? 'បោះបង់' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_km ? 'បញ្ជាក់' : 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _loading = true);
      await _service.markResolved(widget.reportId);
      await _load();
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            _km
                ? 'បានដាក់សម្គាល់របាយការណ៍ថាជាបញ្ហាដោះស្រាយរួចរាល់។'
                : 'Sick report marked as resolved.',
          ),
          backgroundColor: const Color(0xFF034418),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            _km
                ? 'មិនអាចដាក់សម្គាល់ថាជាបញ្ហាដោះស្រាយបានទេ៖ ${error.toString()}'
                : 'Could not mark the sick report as resolved: ${error.toString()}',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _loading = false);
    }
  }

  Widget _content(SickReport r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: r.isResolved
              ? const Color(0xFFE8F5E9)
              : (r.hasVetResponse
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFFFFBEB)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: r.isResolved
                ? const Color(0xFFBBF7D0)
                : (r.hasVetResponse
                      ? const Color(0xFFBAE6FD)
                      : const Color(0xFFFDE68A)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: r.isResolved
                    ? const Color(0xFF16A34A)
                    : (r.hasVetResponse
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFB45309)),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                r.displayStatusLabel(widget.languageCode),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      // Primary Report Overview Card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF034418),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.flockName?.trim().isNotEmpty == true
                            ? r.flockName!
                            : (_km ? 'ហ្វូងមិនស្គាល់' : 'Unknown flock'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _date(r.reportDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _infoBlock(
                    icon: Icons.assignment_outlined,
                    label: _km ? 'ប្រភេទរបាយការណ៍' : 'Report Type',
                    value: _type(r.reportType),
                  ),
                ),
                Expanded(
                  child: _infoBlock(
                    icon: Icons.groups_outlined,
                    label: _km ? 'សត្វរងផលប៉ះពាល់' : 'Affected Birds',
                    value: '${r.affectedCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row(_km ? 'រោគសញ្ញា' : 'Symptoms', r.symptoms, isHighlight: true),
          ],
        ),
      ),
      if (r.photoUrl?.trim().isNotEmpty == true) ...[
        const SizedBox(height: 24),
        _photo(r.photoUrl!),
      ],
      const SizedBox(height: 24),

      // Veterinarian Response or Waiting Status
      if (!r.hasVetResponse)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFB45309),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                _km
                    ? 'កំពុងរង់ចាំការឆ្លើយតបពីពេទ្យសត្វ'
                    : 'Waiting for Veterinarian Response',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _km
                    ? 'របាយការណ៍របស់អ្នកត្រូវបានផ្ញើទៅពេទ្យសត្វរួចរាល់ហើយ'
                    : 'Your report has been submitted for review.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
              ),
            ],
          ),
        )
      else
        _response(r),
      if (r.isResolved) ...[
        const SizedBox(height: 24),
        _resolvedActions(),
      ] else if (r.hasVetResponse) ...[
        const SizedBox(height: 24),
        _decisionActions(),
      ],
    ],
  );

  Widget _infoBlock({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: isHighlight ? const EdgeInsets.all(12) : EdgeInsets.zero,
          decoration: isHighlight
              ? BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                )
              : null,
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _photo(String url) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF034418)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Color(0xFF64748B),
              ),
              const SizedBox(height: 8),
              Text(
                _km ? 'មិនអាចបង្ហាញរូបភាព' : 'Cannot display image',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _response(SickReport r) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBBF7D0)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF15803D).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _km ? 'ការឆ្លើយតបពីពេទ្យសត្វ' : 'Veterinarian Response',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.veterinarianName?.trim().isNotEmpty == true
                        ? r.veterinarianName!
                        : (_km ? 'ពេទ្យសត្វ' : 'Veterinarian'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 16),
        if (r.vetDiagnosis?.trim().isNotEmpty == true) ...[
          _row(_km ? 'ការវិនិច្ឆ័យ' : 'Diagnosis', r.vetDiagnosis!),
          const SizedBox(height: 14),
        ],
        if (r.vetAdvice?.trim().isNotEmpty == true) ...[
          _row(_km ? 'ការណែនាំ' : 'Advice', r.vetAdvice!),
          const SizedBox(height: 14),
        ],
        if (r.recommendedAction?.trim().isNotEmpty == true) ...[
          _row(
            _km ? 'សកម្មភាពដែលណែនាំ' : 'Recommended Action',
            r.recommendedAction!,
          ),
          const SizedBox(height: 14),
        ],
        if (r.respondedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                '${_km ? 'បានឆ្លើយតប៖' : 'Responded:'} ${_dateTime(r.respondedAt!)}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _decisionActions() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _km ? 'បញ្ហាត្រូវបានដោះស្រាយមែនទេ?' : 'Problem solved?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _markResolved,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(_km ? 'បានដោះស្រាយ' : 'Mark as Resolved'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF034418),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    ),
  );

  Widget _resolvedActions() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBBF7D0)),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _km ? '🟢 បានដោះស្រាយ' : '🟢 Resolved',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF15803D),
            ),
          ),
        ),
      ],
    ),
  );
}
