import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/services/vaccine_service.dart';
import 'package:frontend/models/vaccine.dart';

class VaccineModel {
  final String id;

  final String nameEn;
  final String nameKm;

  final String diseaseEn;
  final String diseaseKm;

  final int intervalDays;

  final String? notesEn;
  final String? notesKm;

  VaccineModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.diseaseEn,
    required this.diseaseKm,
    required this.intervalDays,
    this.notesEn,
    this.notesKm,
  });

  factory VaccineModel.fromVaccine(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.id.toString(),

      nameEn: vaccine.nameEn,
      nameKm: vaccine.nameKm,

      diseaseEn: vaccine.diseaseEn,
      diseaseKm: vaccine.diseaseKm,

      intervalDays: vaccine.intervalDays,

      notesEn: vaccine.notesEn,
      notesKm: vaccine.notesKm,
    );
  }

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['vaccine_id']?.toString() ?? '',

      nameEn: json['name_en'] ?? '',
      nameKm: json['name_km'] ?? '',

      diseaseEn: json['disease_en'] ?? '',
      diseaseKm: json['disease_km'] ?? '',

      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,

      notesEn: json['notes_en'],
      notesKm: json['notes_km'],
    );
  }
}

class LogVaccinationStep2Page extends StatefulWidget {
  final String selectedFlockName;
  final String flockId;
  final String languageCode; // 'km' or 'en'
  final String? selectedVaccineId;
  final String? scheduledVaccinationId;

  const LogVaccinationStep2Page({
    super.key,
    required this.selectedFlockName,
    required this.flockId,
    this.languageCode = 'km',
    this.selectedVaccineId,
    this.scheduledVaccinationId,
  });

  @override
  State<LogVaccinationStep2Page> createState() =>
      _LogVaccinationStep2PageState();
}

class _LogVaccinationStep2PageState extends State<LogVaccinationStep2Page> {
  late String _currentLang;
  // String _profileName = '';
  // String _profileImageUrl = '';

  // State Management
  List<VaccineModel> _allVaccines = [];
  List<VaccineModel> _filteredVaccines = [];
  String? _selectedTodayVaccineId;
  String? _selectedNextVaccineId;
  bool _createReminder = true;
  bool _isSaving = false;

  // Date State
  DateTime _administrationDate = DateTime.now();
  DateTime _nextDate = DateTime.now();
  bool _hasSelectedNextDate = false;
  final VaccineService _vaccineService = VaccineService();

  // Attachment Image
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Color Palette Matching Design System
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);

  // Dictionary for Khmer & English Translations
  final Map<String, Map<String, String>> _localizedValues = const {
    'km': {
      'step_badge': 'ជំហានទី ២ នៃ ៣',
      'page_title': 'ជ្រើសរើសវ៉ាក់សាំង',
      'search_hint': 'ស្វែងរកវ៉ាក់សាំង...',
      'subtitle_prefix': 'ជ្រើសរើសវ៉ាក់សាំងជាក់លាក់ដែលកំពុងចាក់ឱ្យក្រុមមាន់',
      'lbl_prevention': 'ការពារ៖',
      'lbl_repeat': 'ចាក់ឡើងវិញ៖',
      'lbl_admin_date': 'ថ្ងៃផ្តល់ឱ្យ',
      'lbl_attach_photo': 'រូបភាព (ជាជម្រើស)',
      'btn_add_photo': 'បញ្ចូលរូបភាព',
      'btn_custom_vac': 'បន្ថែមវ៉ាក់សាំងផ្ទាល់ខ្លួន',
      'btn_back': 'ត្រឡប់ក្រោយ',
      'btn_next': 'ជំហានបន្ទាប់',
      'section_today': 'ការចាក់វ៉ាក់សាំងថ្ងៃនេះ',
      'section_next': 'ការចាក់វ៉ាក់សាំងបន្ទាប់',
      'field_flock': 'ហ្វូង',
      'field_today_vaccine': 'វ៉ាក់សាំងដែលចាក់ថ្ងៃនេះ',
      'field_next_vaccine': 'វ៉ាក់សាំងបន្ទាប់',
      'next_optional': '(ជាជម្រើស)',
      'next_plan_hint': 'រៀបចំផែនការចាក់វ៉ាក់សាំងបន្ទាប់',
      'next_skip': 'រំលងការជ្រើសរើសវ៉ាក់សាំងបន្ទាប់',
      'no_next_scheduled': 'មិនទាន់មានវ៉ាក់សាំងបន្ទាប់ដែលបានកំណត់ទេ',
      'field_next_date': 'កាលបរិច្ឆេទបន្ទាប់',
      'field_reminder': 'បង្កើតការរំលឹក',
      'upload_photo': 'បញ្ចូល',
      'err_select_vac': 'សូមជ្រើសរើសវ៉ាក់សាំងមួយជាមុនសិន',
      'err_select_next_vac': 'សូមជ្រើសរើសវ៉ាក់សាំងបន្ទាប់',
      'err_next_date': 'កាលបរិច្ឆេទបន្ទាប់ត្រូវតែបន្ទាប់ពីថ្ងៃចាក់',
      'err_next_date_required': 'សូមជ្រើសរើសកាលបរិច្ឆេទបន្ទាប់',
      'custom_title': 'បន្ថែមវ៉ាក់សាំងផ្ទាល់ខ្លួន',
      'custom_subtitle': 'បង្កើតវ៉ាក់សាំងថ្មីសម្រាប់កន្លែងចិញ្ចឹមរបស់អ្នក',
      'custom_name_en': 'ឈ្មោះវ៉ាក់សាំង (EN)',
      'custom_name_km': 'ឈ្មោះវ៉ាក់សាំង (KM)',
      'custom_disease_en': 'ជំងឺ (EN)​(Optional)',
      'custom_disease_km': 'ជំងឺ (KM)​ (ជាជម្រើស)',
      'custom_interval': 'ចន្លោះពេលចាក់ (ថ្ងៃ)',
      'custom_notes': 'ចំណាំ (ជាជម្រើស)',
      'custom_sec_name': 'ឈ្មោះវ៉ាក់សាំង',
      'custom_sec_disease': 'ជំងឺដែលការពារ',
      'custom_sec_interval': 'ចន្លោះពេលចាក់ឡើងវិញ',
      'custom_sec_notes': 'ចំណាំ (ជាជម្រើស)',
      'custom_interval_unit': 'ថ្ងៃ',
      'cancel': 'បោះបង់',
      'save': 'រក្សាទុក',
      'next': 'បន្ទាប់',
      'custom_required': 'សូមបំពេញព័ត៌មានចាំបាច់',
      'custom_success': 'វ៉ាក់សាំងផ្ទាល់ខ្លួនត្រូវបានបង្កើតដោយជោគជ័យ',
      'custom_error': 'មិនអាចបង្កើតវ៉ាក់សាំងផ្ទាល់ខ្លួនបានទេ',
    },
    'en': {
      'step_badge': 'STEP 2 OF 3',
      'page_title': 'Select Vaccine',
      'search_hint': 'Search vaccine...',
      'subtitle_prefix': 'Select specific vaccine being administered to flock',
      'lbl_prevention': 'Prevents:',
      'lbl_repeat': 'Repeat Every:',
      'lbl_admin_date': 'Administered Date',
      'lbl_attach_photo': 'Photo (Optional)',
      'btn_add_photo': 'Upload Photo',
      'btn_custom_vac': 'Add custom vaccine',
      'btn_back': 'Back',
      'btn_next': 'Next Step',
      'section_today': 'Today\'s Vaccination',
      'section_next': 'Next Vaccination',
      'field_flock': 'Flock',
      'field_today_vaccine': 'Vaccine Given Today',
      'field_next_vaccine': 'Next Vaccine',
      'next_optional': '(Optional)',
      'next_plan_hint': 'Plan your next vaccination',
      'next_skip': 'Skip next vaccine',
      'no_next_scheduled': 'No next vaccine scheduled yet.',
      'field_next_date': 'Next Date',
      'field_reminder': 'Create Reminder',
      'upload_photo': 'Upload',
      'err_select_vac': 'Please select a vaccine first',
      'err_select_next_vac': 'Please select the next vaccine',
      'err_next_date':
          'The next date must be on or after the administration date',
      'err_next_date_required': 'Please select the next vaccination date',
      'custom_title': 'Add Custom Vaccine',
      'custom_subtitle': 'Create a new vaccine for your flock',
      'custom_name_en': 'Vaccine name (EN)',
      'custom_name_km': 'Vaccine name (KM)',
      'custom_disease_en': 'Disease (EN)​​​(Optional)',
      'custom_disease_km': 'Disease (KM)​ (ជាជម្រើស)',
      'custom_interval': 'Repeat interval (days)',
      'custom_notes': 'Notes (optional)',
      'custom_sec_name': 'Vaccine name',
      'custom_sec_disease': 'Disease prevented',
      'custom_sec_interval': 'Repeat interval',
      'custom_sec_notes': 'Notes (optional)',
      'custom_interval_unit': 'days',
      'cancel': 'Cancel',
      'save': 'Save',
      'next': 'Next',
      'custom_required': 'Please fill in the required fields',
      'custom_success': 'Custom vaccine created successfully',
      'custom_error': 'Could not create custom vaccine',
    },
  };

  @override
  void initState() {
    super.initState();
    // _loadProfile();
    _currentLang = widget.languageCode;
    _fetchVaccines();
    _fetchServerDate();
  }

  /// 1. Fetch Vaccine List from Backend
  Future<void> _fetchVaccines() async {
    try {
      final vaccines = await _vaccineService.fetchVaccines();

      final fetched = vaccines
          .map((item) => VaccineModel.fromVaccine(item))
          .toList();

      setState(() {
        _allVaccines = fetched;

        _filteredVaccines = fetched;

        if (fetched.isNotEmpty) {
          final preferredVaccineId = widget.selectedVaccineId;
          final preferredVaccine =
              preferredVaccineId != null && preferredVaccineId.isNotEmpty
              ? fetched.firstWhere(
                  (vaccine) => vaccine.id == preferredVaccineId,
                  orElse: () => fetched.first,
                )
              : fetched.first;

          _selectedTodayVaccineId = preferredVaccine.id;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 2. Fetch Administration Date from Backend
  Future<void> _fetchServerDate() async {
    if (mounted) {
      setState(() {
        _administrationDate = DateTime.now();
        _nextDate = _administrationDate;
      });
    }
  }

  Future<void> _showCustomVaccineDialog() async {
    final nameEnController = TextEditingController();
    final nameKmController = TextEditingController();
    final diseaseEnController = TextEditingController();
    final diseaseKmController = TextEditingController();
    final intervalController = TextEditingController(text: '0');
    // final notesEnController = TextEditingController();
    // final notesKmController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branded Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  color: brandDarkGreen,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.vaccines,
                          color: brandDarkGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getText('custom_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getText('custom_subtitle'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Form Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getText('custom_sec_name'),
                        style: _dialogSectionStyle,
                      ),
                      const SizedBox(height: 10),
                      _buildCustomVacField(
                        controller: nameEnController,
                        icon: Icons.badge_outlined,
                        hint: _getText('custom_name_en'),
                      ),
                      const SizedBox(height: 12),
                      _buildCustomVacField(
                        controller: nameKmController,
                        icon: Icons.badge_outlined,
                        hint: _getText('custom_name_km'),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _getText('custom_sec_disease'),
                        style: _dialogSectionStyle,
                      ),
                      const SizedBox(height: 10),
                      _buildCustomVacField(
                        controller: diseaseEnController,
                        icon: Icons.health_and_safety_outlined,
                        hint: _getText('custom_disease_en'),
                      ),
                      const SizedBox(height: 12),
                      _buildCustomVacField(
                        controller: diseaseKmController,
                        icon: Icons.health_and_safety_outlined,
                        hint: _getText('custom_disease_km'),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textGrey,
                            side: const BorderSide(color: textGreyLight),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_getText('cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            final nameEn = nameEnController.text.trim();
                            final nameKm = nameKmController.text.trim();
                            final diseaseEn = diseaseEnController.text.trim();
                            final diseaseKm = diseaseKmController.text.trim();
                            final intervalValue = int.tryParse(
                              intervalController.text.trim(),
                            );

                            if (nameEn.isEmpty ||
                                nameKm.isEmpty ||
                                diseaseEn.isEmpty ||
                                diseaseKm.isEmpty ||
                                intervalValue == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getText('custom_required')),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(dialogContext, {
                              'name_en': nameEn,
                              'name_km': nameKm,
                              'disease_en': diseaseEn,
                              'disease_km': diseaseKm,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandDarkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _getText('save'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    try {
      final createdVaccine = await _vaccineService.createVaccine(result);
      final customModel = VaccineModel.fromVaccine(createdVaccine);

      setState(() {
        _allVaccines = [..._allVaccines, customModel];
        _filteredVaccines = [..._filteredVaccines, customModel];
        _selectedTodayVaccineId = customModel.id;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('custom_success'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('custom_error'))));
    }
  }

  TextStyle get _dialogSectionStyle => const TextStyle(
    color: brandDarkGreen,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  Widget _buildCustomVacField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? suffixText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: brandDarkGreen, size: 20),
        suffixText: suffixText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textGreyLight.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandDarkGreen, width: 1.5),
        ),
      ),
    );
  }

  /// Image Picker Logic
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Read image bytes for web compatibility
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = File(image.path);
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _submitVaccinationRecord() async {
    if (_selectedTodayVaccineId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('err_select_vac'))));
      return;
    }
    if (_selectedNextVaccineId != null && !_hasSelectedNextDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getText('err_next_date_required'))),
      );
      return;
    }
    if (_selectedNextVaccineId != null &&
        _hasSelectedNextDate &&
        DateUtils.dateOnly(
          _nextDate,
        ).isBefore(DateUtils.dateOnly(_administrationDate))) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('err_next_date'))));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final todayVaccine = _allVaccines.firstWhere(
        (vaccine) => vaccine.id == _selectedTodayVaccineId,
      );
      final nextVaccine = _selectedNextVaccineId == null
          ? null
          : _allVaccines.firstWhere(
              (vaccine) => vaccine.id == _selectedNextVaccineId,
            );

      final summaryData = {
        'flockId': widget.flockId,
        'flockName': widget.selectedFlockName,
        'vaccineId': todayVaccine.id,
        'vaccinationId': widget.scheduledVaccinationId,
        'nextVaccineId': nextVaccine?.id,
        'todayVaccineName': _currentLang == 'km'
            ? todayVaccine.nameKm
            : todayVaccine.nameEn,
        'nextVaccineName': nextVaccine == null
            ? null
            : (_currentLang == 'km' ? nextVaccine.nameKm : nextVaccine.nameEn),
        'administrationDate': _administrationDate,
        'nextDate': _selectedNextVaccineId == null || !_hasSelectedNextDate
            ? null
            : _nextDate,
        'createReminder': _createReminder,
        'photoPath': _selectedImage?.path,
        'photoBytes': _selectedImageBytes,
        'languageCode': _currentLang,
      };

      if (!mounted) return;
      final result = await context.push<bool>(
        '/log-vaccination-step3/${todayVaccine.id}/$_currentLang',
        extra: summaryData,
      );
      if (result == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('custom_error'))));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
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
    final kmMonths = [
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

    if (_currentLang == 'km') {
      return '${date.day} ${kmMonths[date.month - 1]} ${date.year}';
    }

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getText(String key) {
    final value =
        _localizedValues[_currentLang]?[key] ?? _localizedValues['km']?[key];
    if (value != null) {
      return value;
    }
    // Fallback to key name if translation not found
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('section_today'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: textGreyLight.withValues(alpha: 0.7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        _getText('field_flock'),
                        widget.selectedFlockName,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getText('field_today_vaccine'),
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTodayVaccineId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          if (_allVaccines.isNotEmpty)
                            ..._allVaccines.map((vaccine) {
                              final title = _currentLang == 'km'
                                  ? vaccine.nameKm
                                  : vaccine.nameEn;
                              return DropdownMenuItem(
                                value: vaccine.id,
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTodayVaccineId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getText('lbl_admin_date'),
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _administrationDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _administrationDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: textGrey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(_administrationDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getText('lbl_attach_photo'),
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          _selectedImage == null
                              ? _getText('upload_photo')
                              : 'Photo added',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brandDarkGreen,
                          side: const BorderSide(color: brandDarkGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getText('section_next'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: textGreyLight.withValues(alpha: 0.7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getText('field_next_vaccine')} ${_getText('next_optional')}',
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getText('next_plan_hint'),
                        style: const TextStyle(color: textGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedNextVaccineId ?? '',
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(_getText('next_skip')),
                          ),
                          if (_allVaccines.isNotEmpty)
                            ..._allVaccines.map((vaccine) {
                              final title = _currentLang == 'km'
                                  ? vaccine.nameKm
                                  : vaccine.nameEn;
                              return DropdownMenuItem(
                                value: vaccine.id,
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedNextVaccineId =
                                value == null || value.isEmpty ? null : value;
                            if (_selectedNextVaccineId == null) {
                              _hasSelectedNextDate = false;
                            }
                          });
                        },
                      ),
                      if (_allVaccines.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getText('no_next_scheduled'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_selectedNextVaccineId != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _getText('field_next_date'),
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _nextDate.isBefore(_administrationDate)
                                  ? _administrationDate
                                  : _nextDate,
                              firstDate: DateUtils.dateOnly(
                                _administrationDate,
                              ),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setState(() {
                                _nextDate = picked;
                                _hasSelectedNextDate = true;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: textGrey,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(_nextDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _createReminder,
                            activeColor: brandDarkGreen,
                            onChanged: (value) => setState(
                              () => _createReminder = value ?? false,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _getText('field_reminder'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showCustomVaccineDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: brandDarkGreen,
                              width: 1.2,
                            ),
                            foregroundColor: brandDarkGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(_getText('btn_custom_vac')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitVaccinationRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _getText('btn_next'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textDarkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

}
