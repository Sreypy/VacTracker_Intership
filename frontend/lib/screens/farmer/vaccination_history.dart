import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/services/vaccination_pdf_service.dart';
import 'package:frontend/services/vaccination_service.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';

class VaccinationHistoryScreen extends StatefulWidget {
  final String flockId;
  final String flockDetails;
  final String languageCode; // 'en' or 'km'

  const VaccinationHistoryScreen({
    super.key,
    this.flockId = '0',
    this.flockDetails = '',
    this.languageCode = 'km', // Default to Khmer
  });

  @override
  State<VaccinationHistoryScreen> createState() =>
      _VaccinationHistoryScreenState();
}

class _VaccinationHistoryScreenState extends State<VaccinationHistoryScreen> {
  final FlockService _flockService = FlockService();
  final VaccinationService _vaccinationService = VaccinationService();
  final VaccinationPdfService _pdfService = VaccinationPdfService();

  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);

  static const Color badgeDoneBg = Color(0xFF1B5E20);
  static const Color badgeDoneText = Colors.white;

  static const Color badgeMissedBg = Color(0xFFFFEBEE);
  static const Color badgeMissedText = Color(0xFFC62828);

  static const Color calloutBg = Color(0xFFFFF5F5);
  static const Color calloutText = Color(0xFFC62828);

  bool _isLoading = true;
  String? _errorMessage;
  Flock? _flock;
  List<Map<String, dynamic>> _records = [];
  int _completedCount = 0;
  String _nextDueLabel = '';

  // Localization Dictionary
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'VacTracker',
      'flock_label': 'Flock ID:',
      'history_title': 'Vaccination History',
      'history_subtitle': 'Complete record of health interventions for the',
      'completed': 'Completed',
      'next_due': 'Next Due',
      'recent_records': 'Recent Records',
      'filter': 'Filter',
      'download_pdf': 'Download PDF History',
      'done': 'Done',
      'missed': 'Missed',
      'loading': 'Loading vaccination history...',
      'retry': 'Retry',
      'no_records': 'No vaccination records found yet.',
      'no_data': 'No upcoming date',
    },
    'km': {
      'app_title': 'VacTracker',
      'flock_label': 'លេខសម្គាល់ហ្វូង:',
      'history_title': 'ប្រវត្តិការចាក់វ៉ាក់សាំង',
      'history_subtitle': 'កំណត់ត្រាពេញលេញនៃការថែទាំសុខភាពសម្រាប់',
      'completed': 'បានបញ្ចប់',
      'next_due': 'កំណត់បន្ទាប់',
      'recent_records': 'កំណត់ត្រាថ្មីៗ',
      'filter': 'តម្រង',
      'download_pdf': 'ទាញយកប្រវត្តិជា PDF',
      'done': 'រួចរាល់',
      'missed': 'ខកខាន',
      'loading': 'កំពុងទាញយកប្រវត្តិការចាក់វ៉ាក់សាំង...',
      'retry': 'ព្យាយាមម្តងទៀត',
      'no_records': 'មិនទាន់មានកំណត់ត្រាការចាក់វ៉ាក់សាំងទេ។',
      'no_data': 'គ្មានកាលបរិច្ឆេទជិតដល់',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  Future<void> _loadHistory() async {
    final flockId = int.tryParse(widget.flockId);
    if (flockId == null || flockId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid flock id';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final flock = await _flockService.fetchFlockById(flockId);
      final vaccinations = await _vaccinationService.fetchVaccinationsByFlock(
        flockId,
      );

      final records = <Map<String, dynamic>>[];

      for (final vaccination in vaccinations) {
        final vaccine = vaccination['vaccine'] ?? {};
        final dateGiven = vaccination['date_given'];
        final parsedDate = DateTime.tryParse(dateGiven?.toString() ?? '');
        final admin = vaccination['administered_by'] ?? {};
        final status = (vaccination['status'] ?? 'on_time').toString();

        records.add({
          'title': widget.languageCode == 'km'
              ? (vaccine['name_km'] ?? vaccine['name_en'] ?? 'វ៉ាក់សាំង')
              : (vaccine['name_en'] ?? vaccine['name_km'] ?? 'Vaccine'),
          'subtitle': widget.languageCode == 'km'
              ? (vaccine['disease_km'] ?? vaccine['disease_en'] ?? '')
              : (vaccine['disease_en'] ?? vaccine['disease_km'] ?? ''),
          'status': _getStatusText(status),
          'date': parsedDate == null ? '' : _formatDisplayDate(parsedDate),
          'administrator': admin['name']?.toString(),
          'adminType': admin['name'] != null ? 'person' : null,
          'isMissed': status == 'overdue',
          'note': status == 'overdue' ? _getText('missed') : null,
          'next_due': vaccination['next_due_date'],
          'raw_status': status,
          'date_value': parsedDate,
        });
      }

      records.sort((a, b) {
        final firstDate = a['date_value'] as DateTime?;
        final secondDate = b['date_value'] as DateTime?;
        if (firstDate == null && secondDate == null) return 0;
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });

      DateTime? nextDueDate;
      for (final record in records) {
        final rawDate = record['next_due']?.toString();
        final candidateDate = DateTime.tryParse(rawDate ?? '');
        if (candidateDate != null) {
          if (nextDueDate == null || candidateDate.isBefore(nextDueDate)) {
            nextDueDate = candidateDate;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _flock = flock;
        _records = records;
        _completedCount = records.length;
        _nextDueLabel = nextDueDate == null
            ? _getText('no_data')
            : _formatDisplayDate(nextDueDate);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDisplayDate(DateTime date) {
    if (widget.languageCode == 'km') {
      final months = [
        'មករា',
        'កុម្ភៈ',
        'មីនា',
        'មេសា',
        'ឧសភា',
        'មិថុនា',
        'កក្កដា',
        'សីហា',
        'កញ្ញា',
        'តុលា',
        'វិច្ឆិកា',
        'ធ្នូ',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return _getText('missed');
      case 'due_soon':
        return widget.languageCode == 'km' ? 'ជិតដល់' : 'Due Soon';
      case 'completed':
        return _getText('completed');
      default:
        return _getText('done');
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _getText('app_title'),
          style: const TextStyle(
            color: primaryGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationHeaderButton(
            languageCode: widget.languageCode,
            color: primaryGreen,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                '${_getText('flock_label')} ${widget.flockId}',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getText('history_title'),
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_getText('history_subtitle')} ${_flock?.batchName ?? (widget.flockDetails.isNotEmpty ? widget.flockDetails : widget.flockId)}.',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Metrics Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.verified_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: primaryGreen,
                      label: _getText('completed'),
                      value: _completedCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.medical_services_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: primaryGreen,
                      label: _getText('next_due'),
                      value: _nextDueLabel.isEmpty
                          ? _getText('no_data')
                          : _nextDueLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sub-header & Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getText('recent_records'),
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.filter_list),
                              title: Text(_getText('filter')),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            size: 18,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getText('filter'),
                            style: const TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(color: primaryGreen),
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: calloutText,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: textDark),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadHistory,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryGreen),
                        ),
                        child: Text(_getText('retry')),
                      ),
                    ],
                  ),
                )
              else if (records.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getText('no_records'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: textMuted),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isLast = index == records.length - 1;
                    return _buildTimelineItem(record, isLast);
                  },
                ),
              const SizedBox(height: 24),

              // Download PDF Button
              OutlinedButton.icon(
                onPressed:
                    _isLoading || _errorMessage != null || _records.isEmpty
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final result = await _pdfService.exportHistoryPdf(
                          flockId: widget.flockId,
                          flockName: _flock?.batchName ?? widget.flockDetails,
                          languageCode: widget.languageCode,
                          records: _records.map((record) {
                            return {
                              'title': record['title'],
                              'subtitle': record['subtitle'],
                              'date': record['date'],
                              'status': record['status'],
                            };
                          }).toList(),
                          context: context,
                        );

                        if (!mounted) return;
                        if (result == null) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Unable to export PDF right now.'),
                            ),
                          );
                        }
                      },
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: primaryGreen,
                ),
                label: Text(
                  _getText('download_pdf'),
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> record, bool isLast) {
    final bool isMissed = record['isMissed'] ?? false;
    final Color statusColor = isMissed ? badgeMissedText : primaryGreen;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isMissed ? badgeMissedText : primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMissed ? Icons.error_outline : Icons.vaccines,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: Colors.grey[300])),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: statusColor, width: 4),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                record['title'],
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isMissed ? badgeMissedBg : badgeDoneBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record['status'],
                                style: TextStyle(
                                  color: isMissed
                                      ? badgeMissedText
                                      : badgeDoneText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record['subtitle'],
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),

                        if (isMissed && record['note'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: calloutBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: calloutText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    record['note'],
                                    style: const TextStyle(
                                      color: calloutText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[200], height: 1),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              record['date'],
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (record['administrator'] != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                record['adminType'] == 'facility'
                                    ? Icons.domain_outlined
                                    : Icons.person_outline,
                                size: 16,
                                color: textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record['administrator'],
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return FarmerBottomNavigation(
      currentIndex: 2,
      languageCode: widget.languageCode,
    );
  }
}
