import 'package:flutter/material.dart';
import 'package:frontend/models/sick_report.dart';
import 'package:frontend/services/sick_report_service.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';

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
  final _service = SickReportService();
  SickReport? _report;
  bool _loading = true;
  String? _error;

  bool get _km => widget.languageCode == 'km';

  @override
  void initState() {
    super.initState();
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
      title: Text(
        _km ? 'របាយការណ៍សត្វឈឺ' : 'Sick Report Details',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      foregroundColor: const Color(0xFF034418),
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
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

  Widget _content(SickReport r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
}
