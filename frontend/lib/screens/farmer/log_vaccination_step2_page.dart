import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
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

  const LogVaccinationStep2Page({
    super.key,
    required this.selectedFlockName,
    required this.flockId,
    this.languageCode = 'km',
    this.selectedVaccineId,
  });

  @override
  State<LogVaccinationStep2Page> createState() =>
      _LogVaccinationStep2PageState();
}

class _LogVaccinationStep2PageState extends State<LogVaccinationStep2Page> {
  late String _currentLang;

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
      'field_next_date': 'កាលបរិច្ឆេទបន្ទាប់',
      'field_reminder': 'បង្កើតការរំលឹក',
      'upload_photo': 'បញ្ចូល',
      'err_select_vac': 'សូមជ្រើសរើសវ៉ាក់សាំងមួយជាមុនសិន',
      'custom_title': 'បន្ថែមវ៉ាក់សាំងផ្ទាល់ខ្លួន',
      'custom_name_en': 'ឈ្មោះវ៉ាក់សាំង (EN)',
      'custom_name_km': 'ឈ្មោះវ៉ាក់សាំង (KM)',
      'custom_disease_en': 'ជំងឺ (EN)',
      'custom_disease_km': 'ជំងឺ (KM)',
      'custom_interval': 'ចន្លោះពេលចាក់ (ថ្ងៃ)',
      'custom_notes': 'ចំណាំ (ជាជម្រើស)',
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
      'field_next_date': 'Next Date',
      'field_reminder': 'Create Reminder',
      'upload_photo': 'Upload',
      'err_select_vac': 'Please select a vaccine first',
      'custom_title': 'Add Custom Vaccine',
      'custom_name_en': 'Vaccine name (EN)',
      'custom_name_km': 'Vaccine name (KM)',
      'custom_disease_en': 'Disease (EN)',
      'custom_disease_km': 'Disease (KM)',
      'custom_interval': 'Repeat interval (days)',
      'custom_notes': 'Notes (optional)',
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
          _selectedNextVaccineId = preferredVaccine.id;
          _nextDate = DateTime.now().add(
            Duration(
              days: preferredVaccine.intervalDays > 0
                  ? preferredVaccine.intervalDays
                  : 7,
            ),
          );
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
        _nextDate = _administrationDate.add(const Duration(days: 7));
      });
    }
  }

  Future<void> _showCustomVaccineDialog() async {
    final nameEnController = TextEditingController();
    final nameKmController = TextEditingController();
    final diseaseEnController = TextEditingController();
    final diseaseKmController = TextEditingController();
    final intervalController = TextEditingController(text: '0');
    final notesEnController = TextEditingController();
    final notesKmController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_getText('custom_title')),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameEnController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_name_en'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameKmController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_name_km'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: diseaseEnController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_disease_en'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: diseaseKmController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_disease_km'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: intervalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _getText('custom_interval'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesEnController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_notes'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesKmController,
                    decoration: InputDecoration(
                      labelText: _getText('custom_notes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_getText('cancel')),
            ),
            ElevatedButton(
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
                    SnackBar(content: Text(_getText('custom_required'))),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'name_en': nameEn,
                  'name_km': nameKm,
                  'disease_en': diseaseEn,
                  'disease_km': diseaseKm,
                  'interval_days': intervalValue,
                  'notes_en': notesEnController.text.trim().isEmpty
                      ? null
                      : notesEnController.text.trim(),
                  'notes_km': notesKmController.text.trim().isEmpty
                      ? null
                      : notesKmController.text.trim(),
                });
              },
              child: Text(_getText('save')),
            ),
          ],
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
        _selectedNextVaccineId = customModel.id;
        _nextDate = DateTime.now().add(
          Duration(
            days: customModel.intervalDays > 0 ? customModel.intervalDays : 7,
          ),
        );
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

    setState(() => _isSaving = true);

    try {
      final todayVaccine = _allVaccines.firstWhere(
        (vaccine) => vaccine.id == _selectedTodayVaccineId,
      );
      final nextVaccine = _allVaccines.firstWhere(
        (vaccine) =>
            vaccine.id == (_selectedNextVaccineId ?? _selectedTodayVaccineId),
      );

      final summaryData = {
        'flockId': widget.flockId,
        'flockName': widget.selectedFlockName,
        'vaccineId': todayVaccine.id,
        'todayVaccineName': _currentLang == 'km'
            ? todayVaccine.nameKm
            : todayVaccine.nameEn,
        'nextVaccineName': _currentLang == 'km'
            ? nextVaccine.nameKm
            : nextVaccine.nameEn,
        'administrationDate': _administrationDate,
        'nextDate': _nextDate,
        'createReminder': _createReminder,
        'photoPath': _selectedImage?.path,
        'photoBytes': _selectedImageBytes,
        'languageCode': _currentLang,
      };

      if (!mounted) return;
      context.push(
        '/log-vaccination-step3/${todayVaccine.id}/$_currentLang',
        extra: summaryData,
      );
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
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: brandDarkGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _getText('page_title'),
          style: const TextStyle(
            color: brandDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Step Progress Chip Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: brandDarkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getText('step_badge'),
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
              Text(
                _getText('section_today'),
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
                                child: Text(title),
                              );
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTodayVaccineId = value;
                            _selectedNextVaccineId =
                                value ?? _selectedNextVaccineId;
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
                        _getText('field_next_vaccine'),
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedNextVaccineId,
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
                                child: Text(title),
                              );
                            }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedNextVaccineId = value;
                            final selectedVaccine = _allVaccines.firstWhere(
                              (item) => item.id == value,
                              orElse: () => _allVaccines.isNotEmpty
                                  ? _allVaccines.first
                                  : VaccineModel(
                                      id: '',
                                      nameEn: '',
                                      nameKm: '',
                                      diseaseEn: '',
                                      diseaseKm: '',
                                      intervalDays: 7,
                                    ),
                            );
                            _nextDate = _administrationDate.add(
                              Duration(
                                days: selectedVaccine.intervalDays > 0
                                    ? selectedVaccine.intervalDays
                                    : 7,
                              ),
                            );
                          });
                        },
                      ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(_nextDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
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
      bottomNavigationBar: _buildBottomNav(),
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

  Widget _buildBottomNav() {
    return FarmerBottomNavigation(
      currentIndex: 1,
      languageCode: _currentLang,
    );
  }
}

// use ImageSource from `package:image_picker` (remove local shim)
