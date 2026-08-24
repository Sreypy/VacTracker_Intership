import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class VetSickReportsScreen extends StatefulWidget {
  final String languageCode;

  const VetSickReportsScreen({super.key, this.languageCode = 'en'});

  @override
  State<VetSickReportsScreen> createState() => _VetSickReportsScreenState();
}

class _VetSickReportsScreenState extends State<VetSickReportsScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // Status Colors
  static const Color statusNew = Color(0xFFDC2626); // Red
  static const Color statusReviewing = Color(0xFFF59E0B); // Amber
  static const Color statusResolved = Color(0xFF10B981); // Green

  static const Color statusNewBg = Color(0xFFFEE2E2);
  static const Color statusReviewingBg = Color(0xFFFEF3C7);
  static const Color statusResolvedBg = Color(0xFFD1FAE5);

  // State
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _reports = [];
  String? _selectedFilter;

  // Localization
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Sick Reports',
      'subtitle': 'Review health reports from your farmers',
      'filter_all': 'All',
      'filter_new': 'New',
      'filter_reviewing': 'Reviewing',
      'filter_resolved': 'Resolved',
      'loading': 'Loading reports...',
      'load_error': 'Could not load sick reports.',
      'retry': 'Retry',
      'no_reports': 'No sick reports found',
      'no_reports_subtitle': 'All your farmers\' flocks are healthy!',
      'new_badge': 'NEW',
      'reviewing_badge': 'REVIEWING',
      'resolved_badge': 'RESOLVED',
      'btn_review': 'Review Report',
      'btn_continue': 'Continue Review',
      'btn_view': 'View Report',
      'label_symptoms': 'Symptoms',
      'label_affected': 'affected',
      'label_chickens': 'chickens',
    },
    'km': {
      'title': 'របាយការណ៍សត្វឈឺ',
      'subtitle': 'ពិនិត្យរបាយការណ៍សុខភាពពីកសិកររបស់អ្នក',
      'filter_all': 'ទាំងអស់',
      'filter_new': 'ថ្មី',
      'filter_reviewing': 'កំពុងពិនិត្យ',
      'filter_resolved': 'បានដោះស្រាយ',
      'loading': 'កំពុងផ្ទុករបាយការណ៍...',
      'load_error': 'មិនអាចផ្ទុករបាយការណ៍សត្វឈឺបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
      'no_reports': 'មិនមានរបាយការណ៍សត្វឈឺ',
      'no_reports_subtitle': 'ហ្វូងទាំងអស់របស់កសិករមានសុខភាពល្អ!',
      'new_badge': 'ថ្មី',
      'reviewing_badge': 'កំពុងពិនិត្យ',
      'resolved_badge': 'បានដោះស្រាយ',
      'btn_review': 'ពិនិត្យរបាយការណ៍',
      'btn_continue': 'បន្តការពិនិត្យ',
      'btn_view': 'មើលរបាយការណ៍',
      'label_symptoms': 'រោគសញ្ញា',
      'label_affected': 'សត្វរងផលប៉ះពាល់',
      'label_chickens': 'ក្បាល',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _selectedFilter = _getText('filter_all');
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Authentication token is missing.');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/sick-reports'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final List<dynamic> reports = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        _reports = reports.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${_getText('load_error')} ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    if (_selectedFilter == null || _selectedFilter == _getText('filter_all')) {
      return _reports;
    }

    String statusFilter;
    if (_selectedFilter == _getText('filter_new')) {
      statusFilter = 'pending';
    } else if (_selectedFilter == _getText('filter_reviewing')) {
      statusFilter = 'reviewed';
    } else if (_selectedFilter == _getText('filter_resolved')) {
      statusFilter = 'resolved';
    } else {
      return _reports;
    }

    return _reports
        .where((report) => report['status'] == statusFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusNew;
      case 'reviewed':
        return statusReviewing;
      case 'resolved':
        return statusResolved;
      default:
        return textMuted;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusNewBg;
      case 'reviewed':
        return statusReviewingBg;
      case 'resolved':
        return statusResolvedBg;
      default:
        return Colors.grey[200]!;
    }
  }

  String _getStatusBadgeText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _getText('new_badge');
      case 'reviewed':
        return _getText('reviewing_badge');
      case 'resolved':
        return _getText('resolved_badge');
      default:
        return status.toUpperCase();
    }
  }

  String _getButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _getText('btn_review');
      case 'reviewed':
        return _getText('btn_continue');
      case 'resolved':
        return _getText('btn_view');
      default:
        return _getText('btn_view');
    }
  }

  Color _getButtonColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusNew;
      case 'reviewed':
        return statusReviewing;
      case 'resolved':
        return statusResolved;
      default:
        return primaryGreen;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _getText('title'),
          style: const TextStyle(
            color: primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: Text(_getText('loading')))
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadReports,
              color: primaryGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      _getText('title'),
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Text(
                      _getText('subtitle'),
                      style: const TextStyle(color: textMuted, fontSize: 16),
                    ),
                  ),
                  // Filter Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildFilterChip(_getText('filter_all')),
                        const SizedBox(width: 8),
                        _buildFilterChip(_getText('filter_new')),
                        const SizedBox(width: 8),
                        _buildFilterChip(_getText('filter_reviewing')),
                        const SizedBox(width: 8),
                        _buildFilterChip(_getText('filter_resolved')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _getFilteredReports().isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            children: _getFilteredReports()
                                .map((report) => _buildReportCard(report))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textDark,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : _getText('filter_all');
          });
        },
        backgroundColor: cardBg,
        selectedColor: primaryGreen,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primaryGreen : inputBorder,
            width: isSelected ? 0 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.cloud_off_outlined, size: 56, color: textMuted),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textDark),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, color: primaryGreen),
            label: Text(
              _getText('retry'),
              style: const TextStyle(color: primaryGreen),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryGreen),
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
          Icon(Icons.health_and_safety_outlined, size: 64, color: textMuted),
          const SizedBox(height: 14),
          Text(
            _getText('no_reports'),
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('no_reports_subtitle'),
            style: const TextStyle(color: textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);
    final statusBadge = _getStatusBadgeText(status);
    final buttonText = _getButtonText(status);
    final buttonColor = _getButtonColor(status);

    final flock = report['flock'] as Map<String, dynamic>? ?? {};
    final batchName = flock['batch_name']?.toString() ?? 'Unknown Flock';
    final farmName = flock['farm_name']?.toString() ?? '';

    final reportType = report['reportType']?.toString() ?? 'disease';
    final affectedCount = report['affectedCount']?.toString() ?? '0';
    final reportDate = report['reportDate']?.toString() ?? '';
    final symptoms = report['symptoms']?.toString() ?? '';

    // Parse symptoms
    final symptomList = symptoms.split(',').map((s) => s.trim()).toList();
    final symptomsText = symptomList.take(3).join(', ');
    final hasMoreSymptoms = symptomList.length > 3;

    // Format date
    String formattedDate = reportDate;
    if (reportDate.isNotEmpty) {
      try {
        final date = DateTime.parse(reportDate);
        formattedDate =
            '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
      } catch (e) {
        formattedDate = reportDate;
      }
    }

    final reportId = report['report_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '/vet-reports/$reportId?lang=${widget.languageCode}',
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusBadge,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Flock info
              Row(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    size: 18,
                    color: textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$batchName${farmName.isNotEmpty ? " • $farmName" : ""}',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Report type and affected count
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reportType.toUpperCase(),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$affectedCount ${_getText('label_chickens')} ${_getText('label_affected')}',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Symptoms
              if (symptoms.isNotEmpty) ...[
                Text(
                  '${_getText('label_symptoms')}:',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$symptomsText${hasMoreSymptoms ? "..." : ""}',
                  style: TextStyle(color: textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/vet-reports/$reportId?lang=${widget.languageCode}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
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

  Widget _buildBottomNav() {
    int currentIndex = 1; // Reports tab is active

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: inputBorder, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            context.go('/vet-dashboard?lang=${widget.languageCode}');
          } else if (index == 1) {
            // Already on reports screen
          } else if (index == 2) {
            context.go('/my-farmers/${widget.languageCode}');
          } else if (index == 3) {
            context.go('/vet-profile/${widget.languageCode}');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, size: 24),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded, size: 24),
            label: 'Farmers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
