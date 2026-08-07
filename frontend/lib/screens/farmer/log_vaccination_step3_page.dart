import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/models/vaccine.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/services/vaccine_service.dart';
import 'package:frontend/services/vaccination_service.dart';

class LogVaccinationStep3Page extends StatefulWidget {
  final String flockId;
  final String vaccineId;
  final String languageCode; // 'km' or 'en'
  final String flockName;
  final Map<String, dynamic>? summaryData;

  const LogVaccinationStep3Page({
    super.key,
    required this.flockId,
    required this.vaccineId,
    this.languageCode = 'km',
    this.flockName = '',
    this.summaryData,
  });

  @override
  State<LogVaccinationStep3Page> createState() =>
      _LogVaccinationStep3PageState();
}

class _LogVaccinationStep3PageState extends State<LogVaccinationStep3Page> {
  int _currentIndex = 1; // Vaccine tab active
  late String _currentLang;

  // Data State
  bool _isLoading = true;
  bool _isSubmitting = false;

  String _vaccineName = '...';
  String _flockName = '...';
  String _dateGiven = '...';
  String _nextVaccineName = '...';
  String _nextVaccinationDate = '...';
  String _statusBadge = 'ទាន់ពេលវេលា'; // On Time
  bool _createReminder = false;
  String? _photoPath;

  final VaccineService _vaccineService = VaccineService();
  final FlockService _flockService = FlockService();
  final VaccinationService _vaccinationService = VaccinationService();

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color cardBorderGreen = Color(0xFF108038);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color bannerGreenBg = Color(0xFF135D29);
  static const Color statusBadgeBg = Color(0xFFE2ECE4);

  // Khmer & English Translations
  final Map<String, Map<String, String>> _localizedValues = const {
    'km': {
      'app_bar_title': 'ជ្រើសរើសវ៉ាក់សាំង',
      'step_badge_appbar': 'ជំហានទី ២ នៃ ៣',
      'step_text_header': 'ជំហានទី ៣ នៃ ៣',
      'percentage_header': '១០០%',
      'page_title': 'បញ្ជាក់ការចាក់វ៉ាក់សាំង',
      'subtitle': 'សូមពិនិត្យព័ត៌មានលម្អិតខាងក្រោមមុនពេលរក្សាទុក។',
      'lbl_vaccine': 'វ៉ាក់សាំង (VACCINE)',
      'lbl_flock': 'ក្រុមមាន់ (Flock)',
      'lbl_date_given': 'ថ្ងៃចាក់ (Date Given)',
      'lbl_next_vac': 'ចាក់លើកក្រោយ (Next Vaccination)',
      'lbl_next_vaccine': 'វ៉ាក់សាំងបន្ទាប់',
      'lbl_reminder': 'ការរំលឹក',
      'reminder_on': 'បានបើក',
      'reminder_off': 'មិនបានបើក',
      'lbl_status_on_time': 'ទាន់ពេលវេលា',
      'banner_text':
          'ប័ណ្ណបញ្ជាក់សុខភាព\nមាន់របស់អ្នកនឹងទទួលបានវិញ្ញាបនបត្រសុខភាពឌីជីថលភ្លាមៗ។',
      'btn_confirm': 'បញ្ជាក់ និងរក្សាទុក',
      'btn_cancel': 'បោះបង់',
      'msg_success': 'បានកត់ត្រាការចាក់វ៉ាក់សាំងជោគជ័យ!',
      'msg_failed': 'ការកត់ត្រាបរាជ័យ សូមព្យាយាមម្តងទៀត',
    },
    'en': {
      'app_bar_title': 'Select Vaccine',
      'step_badge_appbar': 'STEP 2 OF 3',
      'step_text_header': 'STEP 3 OF 3',
      'percentage_header': '100%',
      'page_title': 'Confirm Vaccination',
      'subtitle': 'Please review the details below before saving.',
      'lbl_vaccine': 'VACCINE',
      'lbl_flock': 'Flock',
      'lbl_date_given': 'Date Given',
      'lbl_next_vac': 'Next Vaccination',
      'lbl_next_vaccine': 'Next Vaccine',
      'lbl_reminder': 'Reminder',
      'reminder_on': 'Enabled',
      'reminder_off': 'Disabled',
      'lbl_status_on_time': 'On Time',
      'banner_text':
          'Health Certificate\nYour flock will receive a digital health certificate immediately.',
      'btn_confirm': 'Confirm & Save',
      'btn_cancel': 'Cancel',
      'msg_success': 'Vaccination record saved successfully!',
      'msg_failed': 'Failed to save record. Please try again.',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    if (widget.flockName.isNotEmpty) {
      _flockName = widget.flockName;
    }
    if (widget.summaryData != null) {
      _populateFromSummary(widget.summaryData!);
    } else {
      _fetchSummaryDetails();
    }
  }

  /// Fetch Summary Details from Backend API
  Future<void> _fetchSummaryDetails() async {
    try {
      final vaccineFuture = _vaccineService.fetchVaccineById(
        int.parse(widget.vaccineId),
      );

      final flockFuture = _flockService.fetchFlockById(
        int.parse(widget.flockId),
      );

      final results = await Future.wait([vaccineFuture, flockFuture]);

      final vaccine = results[0] as Vaccine;

      final flock = results[1] as Flock;

      final now = DateTime.now();

      final formattedDate =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';

      DateTime nextDate = now.add(Duration(days: vaccine.intervalDays));

      final formattedNextDate =
          '${nextDate.day.toString().padLeft(2, '0')}/'
          '${nextDate.month.toString().padLeft(2, '0')}/'
          '${nextDate.year}';

      setState(() {
        _vaccineName = widget.languageCode == 'km'
            ? vaccine.nameKm
            : vaccine.nameEn;

        _flockName = flock.batchName;

        _dateGiven = formattedDate;
        _nextVaccineName = widget.languageCode == 'km'
            ? vaccine.nameKm
            : vaccine.nameEn;
        _nextVaccinationDate = formattedNextDate;

        _statusBadge = _getText('lbl_status_on_time');

        _photoPath = null;

        _isLoading = false;
      });
    } catch (e) {
      _useFallbackData();
    }
  }

  void _populateFromSummary(Map<String, dynamic> data) {
    final adminDate = data['administrationDate'] is DateTime
        ? data['administrationDate'] as DateTime
        : DateTime.tryParse(data['administrationDate']?.toString() ?? '') ??
              DateTime.now();
    final nextDate = data['nextDate'] is DateTime
        ? data['nextDate'] as DateTime
        : DateTime.tryParse(data['nextDate']?.toString() ?? '') ??
              adminDate.add(const Duration(days: 7));

    if (mounted) {
      setState(() {
        _vaccineName = data['todayVaccineName']?.toString() ?? '...';
        _flockName = data['flockName']?.toString() ?? widget.flockName;
        _dateGiven = _formatDate(adminDate);
        _nextVaccineName = data['nextVaccineName']?.toString() ?? '...';
        _nextVaccinationDate = _formatDate(nextDate);
        _createReminder = data['createReminder'] == true;
        _photoPath = data['photoPath']?.toString();
        _statusBadge = _getText('lbl_status_on_time');
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  void _useFallbackData() {
    if (mounted) {
      setState(() {
        _vaccineName = 'វ៉ាក់សាំងញូកាស';
        _flockName = 'Chicken Batch A (មាន់ ៥០០ ក្បាល)';
        _dateGiven = '២២/០២/២០២៦';
        _nextVaccineName = 'វ៉ាក់សាំងញូកាស';
        _nextVaccinationDate = '១២/០៣/២០២៦';
        _statusBadge = _getText('lbl_status_on_time');
        _isLoading = false;
      });
    }
  }

  /// Submit Final Record to Backend
  Future<void> _submitVaccinationRecord() async {
    setState(() => _isSubmitting = true);

    try {
      final summaryData = widget.summaryData;
      final vaccineId =
          summaryData?['vaccineId']?.toString() ?? widget.vaccineId;
      final flockId = summaryData?['flockId']?.toString() ?? widget.flockId;
      final administrationDate = summaryData?['administrationDate'] is DateTime
          ? summaryData!['administrationDate'] as DateTime
          : DateTime.now();

      await _vaccinationService.createVaccination({
        'flock_id': int.parse(flockId),
        'vaccine_id': int.parse(vaccineId),
        'date_given': administrationDate.toIso8601String(),
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_getText('msg_success'))));
        context.go('/farmer-dashboard?lang=$_currentLang');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_getText('msg_failed'))));
      }
    }
  }

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ??
        _localizedValues['km']![key]!;
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
          icon: const Icon(Icons.arrow_back, color: brandDarkGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _getText('app_bar_title'),
          style: const TextStyle(
            color: brandDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: brandDarkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getText('step_badge_appbar'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              // Header Step Text & 100% Progress Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getText('step_text_header'),
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _getText('percentage_header'),
                    style: const TextStyle(
                      color: brandDarkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Full Green Progress Line
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: brandDarkGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 18),

              // Title & Subtitle
              Text(
                _getText('page_title'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getText('subtitle'),
                style: const TextStyle(color: textGrey, fontSize: 13),
              ),

              const SizedBox(height: 18),

              // Main Summary Details Card
              _buildSummaryCard(),

              const SizedBox(height: 16),

              // Digital Health Certificate Banner Card
              _buildHealthCertificateBanner(),

              const SizedBox(height: 16),

              // Tablet Preview / Attached Photo Card
              _buildPhotoPreviewCard(),

              const SizedBox(height: 24),

              // Confirm and Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitVaccinationRecord,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                  label: Text(
                    _getText('btn_confirm'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDarkGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/farmer-dashboard?lang=$_currentLang');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: textGrey, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getText('btn_cancel'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Summary Card Widget matching exact mock design
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Border Indicator Bar
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: cardBorderGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: brandDarkGreen),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vaccine Header & On-Time Status Chip
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusBadgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.vaccines,
                                  color: brandDarkGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getText('lbl_vaccine'),
                                      style: const TextStyle(
                                        color: textGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _vaccineName,
                                      style: const TextStyle(
                                        color: textDarkBlue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBadgeBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: brandDarkGreen,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _statusBadge,
                                      style: const TextStyle(
                                        color: brandDarkGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Flock Info
                          Text(
                            _getText('lbl_flock'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.group_outlined,
                                color: textDarkBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _flockName,
                                style: const TextStyle(
                                  color: textDarkBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Date Given Info
                          Text(
                            _getText('lbl_date_given'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: textDarkBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateGiven,
                                style: const TextStyle(
                                  color: textDarkBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Next Vaccination Inner Sub-Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                left: BorderSide(
                                  color: cardBorderGreen,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getText('lbl_next_vac'),
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: brandDarkGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _nextVaccinationDate,
                                        style: const TextStyle(
                                          color: brandDarkGreen,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _getText('lbl_next_vaccine'),
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _nextVaccineName,
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _getText('lbl_reminder'),
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _createReminder
                                      ? _getText('reminder_on')
                                      : _getText('reminder_off'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Green Health Certificate Badge Banner
  Widget _buildHealthCertificateBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerGreenBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _getText('banner_text'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tablet Image Card Component
  Widget _buildPhotoPreviewCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: _photoPath != null && _photoPath!.isNotEmpty
            ? Image.file(File(_photoPath!), fit: BoxFit.cover)
            : Image.network(
                'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE2E8F0),
                  child: const Center(
                    child: Icon(
                      Icons.tablet_mac_rounded,
                      size: 48,
                      color: textGrey,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            context.go('/farmer-dashboard?lang=$_currentLang');
          } else if (index == 4) {
            context.go('/farmer-profile/$_currentLang');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey.withValues(alpha: 0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: brandDarkGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.vaccines,
                color: brandDarkGreen,
                size: 24,
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 26),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined, size: 26),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 26),
            label: '',
          ),
        ],
      ),
    );
  }
}
