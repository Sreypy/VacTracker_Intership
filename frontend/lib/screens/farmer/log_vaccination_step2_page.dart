import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/vaccine_service.dart';
import 'package:frontend/models/vaccine.dart';

class VaccineModel {
  final String id;
  final String name;
  final String diseaseTarget;
  final int intervalDays;
  final String? notes;

  VaccineModel({
    required this.id,
    required this.name,
    required this.diseaseTarget,
    required this.intervalDays,
    this.notes,
  });

  factory VaccineModel.fromVaccine(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.vaccineId.toString(),
      name: vaccine.name,
      diseaseTarget: vaccine.diseaseTarget,
      intervalDays: vaccine.intervalDays,
      notes: vaccine.notes,
    );
  }

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['vaccine_id']?.toString() ?? '',
      name: json['name'] ?? '',
      diseaseTarget: json['disease_target'] ?? '',
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }
}

class LogVaccinationStep2Page extends StatefulWidget {
  final String selectedFlockName;
  final String flockId;
  final String languageCode; // 'km' or 'en'

  const LogVaccinationStep2Page({
    super.key,
    required this.selectedFlockName,
    required this.flockId,
    this.languageCode = 'km',
  });

  @override
  State<LogVaccinationStep2Page> createState() =>
      _LogVaccinationStep2PageState();
}

class _LogVaccinationStep2PageState extends State<LogVaccinationStep2Page> {
  int _currentIndex = 1; // Vaccination tab selected
  late String _currentLang;

  // State Management
  List<VaccineModel> _allVaccines = [];
  List<VaccineModel> _filteredVaccines = [];
  String? _selectedVaccineId;
  bool _isLoadingVaccines = true;

  // Date State
  String _administrationDate = '22/07/2026';
  bool _isLoadingDate = true;

  final VaccineService _vaccineService = VaccineService();

  // Attachment Image
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _searchController = TextEditingController();

  // Color Palette Matching Design System
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color buttonGreyBg = Color(0xFF769B82);

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
      'lbl_attach_photo': 'បញ្ចូលរូបភាពការចាក់វ៉ាក់សាំង',
      'btn_add_photo': '+ បន្ថែមរូបថត',
      'btn_back': 'ត្រឡប់ក្រោយ',
      'btn_next': 'បន្ទាប់',
      'err_select_vac': 'សូមជ្រើសរើសវ៉ាក់សាំងមួយជាមុនសិន',
    },
    'en': {
      'step_badge': 'STEP 2 OF 3',
      'page_title': 'Select Vaccine',
      'search_hint': 'Search vaccine...',
      'subtitle_prefix': 'Select specific vaccine being administered to flock',
      'lbl_prevention': 'Prevents:',
      'lbl_repeat': 'Repeat Every:',
      'lbl_admin_date': 'Administered Date',
      'lbl_attach_photo': 'Attach Vaccination Photo',
      'btn_add_photo': '+ Add Photo',
      'btn_back': 'Back',
      'btn_next': 'Next',
      'err_select_vac': 'Please select a vaccine first',
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
        if (_allVaccines.isNotEmpty) {
          _selectedVaccineId = _allVaccines.first.id;
        }
        _isLoadingVaccines = false;
      });
    } catch (e) {
      _useFallbackVaccines();
    }
  }

  void _useFallbackVaccines() {
    final mockVaccines = [
      VaccineModel(
        id: '1',
        name: 'Newcastle Vaccine',
        diseaseTarget: 'Newcastle Disease',
        intervalDays: 21,
        notes: 'Use for young birds',
      ),
      VaccineModel(
        id: '2',
        name: 'Gumboro IBD',
        diseaseTarget: 'Gumboro Disease',
        intervalDays: 14,
        notes: 'Booster recommended',
      ),
    ];

    if (mounted) {
      setState(() {
        _allVaccines = mockVaccines;
        _filteredVaccines = mockVaccines;
        _selectedVaccineId = '1';
        _isLoadingVaccines = false;
      });
    }
  }

  /// 2. Fetch Administration Date from Backend
  Future<void> _fetchServerDate() async {
    final now = DateTime.now();
    final formatted =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    if (mounted) {
      setState(() {
        _administrationDate = formatted;
        _isLoadingDate = false;
      });
    }
  }

  /// Image Picker Logic
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _filterVaccines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVaccines = _allVaccines;
      } else {
        _filteredVaccines = _allVaccines.where((v) {
          return v.name.toLowerCase().contains(query.toLowerCase()) ||
              v.diseaseTarget.toLowerCase().contains(query.toLowerCase()) ||
              (v.notes ?? '').toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
              // Search Input Box
              TextField(
                controller: _searchController,
                onChanged: _filterVaccines,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _getText('search_hint'),
                  hintStyle: const TextStyle(color: textGrey, fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: textGrey,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Description Text
              Text.rich(
                TextSpan(
                  text: '${_getText('subtitle_prefix')}\n',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: widget.selectedFlockName,
                      style: const TextStyle(
                        color: brandDarkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // List of Vaccines
              _isLoadingVaccines
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(color: brandDarkGreen),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVaccines.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vaccine = _filteredVaccines[index];
                        final isSelected = _selectedVaccineId == vaccine.id;
                        return _buildVaccineCard(vaccine, isSelected);
                      },
                    ),

              const SizedBox(height: 20),

              // Administration Date Field Box
              Text(
                _getText('lbl_admin_date'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: textGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    _isLoadingDate
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: brandDarkGreen,
                            ),
                          )
                        : Text(
                            _administrationDate,
                            style: const TextStyle(
                              color: textDarkBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Photo Attachment Section
              Text(
                _getText('lbl_attach_photo'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textGreyLight, width: 1.5),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: textGrey,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getText('btn_add_photo'),
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // Bottom Action Buttons Row
              Row(
                children: [
                  // Back Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: brandDarkGreen,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getText('btn_back'),
                          style: const TextStyle(
                            color: brandDarkGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Next Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedVaccineId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_getText('err_select_vac')),
                              ),
                            );
                            return;
                          }

                          // Navigate to Step 3 (pass batchTitle encoded and flockId as query)
                          final encodedBatch = Uri.encodeQueryComponent(
                            widget.selectedFlockName,
                          );
                          final url =
                              '/log-vaccination-step3/$_selectedVaccineId/$_currentLang?flockId=${widget.flockId}&batchTitle=$encodedBatch';
                          debugPrint('Navigating to: $url');
                          try {
                            context.push(url);
                          } catch (e, st) {
                            debugPrint('Navigation error: $e\n$st');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Navigation failed: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonGreyBg,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getText('btn_next'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Individual Vaccine Item Card Widget
  Widget _buildVaccineCard(VaccineModel vaccine, bool isSelected) {
    final title = vaccine.name;
    final subtitle = vaccine.diseaseTarget;
    final interval = '${vaccine.intervalDays} days';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVaccineId = vaccine.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandDarkGreen : textGreyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: brandDarkGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.vaccines,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(color: textGrey, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: textGreyLight),
            const SizedBox(height: 12),

            Row(
              children: [
                // Prevention Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getText('lbl_prevention'),
                        style: const TextStyle(color: textGrey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Repeat Schedule Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getText('lbl_repeat'),
                        style: const TextStyle(color: textGrey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        interval,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vaccine.notes != null &&
                          vaccine.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          vaccine.notes!,
                          style: const TextStyle(color: textGrey, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
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

// use ImageSource from `package:image_picker` (remove local shim)
