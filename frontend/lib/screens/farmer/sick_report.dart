import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/services/storage_service.dart';

class SickReportScreen extends StatefulWidget {
  final String languageCode; // 'en' or 'km'

  const SickReportScreen({super.key, this.languageCode = 'en'});

  @override
  State<SickReportScreen> createState() => _SickReportScreenState();
}

class _SickReportScreenState extends State<SickReportScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // Form State
  final FlockService _flockService = FlockService();
  final TextEditingController _affectedCountController =
      TextEditingController();
  List<Flock> _flocks = [];
  int? _selectedFlockId;
  final List<String> _selectedSymptoms = [];
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  late String _languageCode;

  // Localization Dictionary
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'page_title': 'Sick Report',
      'header_title': 'Report Flock Illness',
      'header_subtitle':
          'Provide details about the symptoms observed to help our veterinarians provide a quick diagnosis.',
      'select_flock': 'Select Flock',
      'visual_evidence': 'Visual Evidence',
      'add_photo': 'Add Photo',
      'photo_hint':
          'Upload clear photos of affected birds for faster diagnostic support.',
      'observed_symptoms': 'Observed Symptoms',
      'symptom_lethargy': 'Lethargy / Weakness',
      'symptom_respiratory': 'Respiratory Issues',
      'symptom_diarrhea': 'Diarrhea / Droppings',
      'symptom_appetite': 'Loss of Appetite',
      'symptom_mortality': 'Sudden Mortality',
      'symptom_other': 'Other...',
      'additional_details': 'Additional Details',
      'details_placeholder':
          'Describe when it started, how many birds are affected, or any other details...',
      'submit_btn': 'Submit Report',
      'affected_count': 'Affected Birds',
      'loading': 'Loading your flocks...',
      'no_flocks': 'No flocks found. Add a flock before reporting illness.',
      'required_flock': 'Please select a flock.',
      'required_count': 'Enter the number of affected birds.',
      'success': 'Sick report submitted successfully.',
      'failed': 'Could not submit sick report.',
    },
    'km': {
      'page_title': 'របាយការណ៍សត្វឈឺ',
      'header_title': 'រាយការណ៍អំពីជំងឺហ្វូងសត្វ',
      'header_subtitle':
          'ផ្តល់ព័ត៌មានលម្អិតអំពីរោគសញ្ញាដែលបានសង្កេតឃើញ ដើម្បីជួយគ្រូពេទ្យសត្វធ្វើរោគវិនិច្ឆ័យបានឆាប់រហ័ស។',
      'select_flock': 'ជ្រើសរើសហ្វូង',
      'visual_evidence': 'ភស្តុតាងរូបភាព',
      'add_photo': 'បន្ថែមរូបថត',
      'photo_hint':
          'បង្ហោះរូបថតច្បាស់ៗនៃសត្វដែលប៉ះពាល់ ដើម្បីទទួលបានការគាំទ្ររោគវិនិច្ឆ័យលឿនជាងមុន។',
      'observed_symptoms': 'រោគសញ្ញាដែលបានសង្កេត',
      'symptom_lethargy': 'ល្ហិតល្ហៃ / ខ្សោយ',
      'symptom_respiratory': 'បញ្ហាផ្លូវដង្ហើម',
      'symptom_diarrhea': 'រាគ / លាមកមិនធម្មតា',
      'symptom_appetite': 'បាត់បង់ការឃ្លានអាហារ',
      'symptom_mortality': 'ការងាប់ភ្លាមៗ',
      'symptom_other': 'ផ្សេងៗ...',
      'additional_details': 'ព័ត៌មានលម្អិតបន្ថែម',
      'details_placeholder':
          'រៀបរាប់ពីពេលដែលវាចាប់ផ្តើម ចំនួនសត្វដែលរងផលប៉ះពាល់ ឬព័ត៌មានលម្អិតផ្សេងទៀត...',
      'submit_btn': 'ផ្ញើរបាយការណ៍',
      'affected_count': 'ចំនួនសត្វដែលរងផលប៉ះពាល់',
      'loading': 'កំពុងផ្ទុកហ្វូងរបស់អ្នក...',
      'no_flocks': 'រកមិនឃើញហ្វូងទេ។ សូមបន្ថែមហ្វូងមុនរាយការណ៍។',
      'required_flock': 'សូមជ្រើសរើសហ្វូង។',
      'required_count': 'សូមបញ្ចូលចំនួនសត្វដែលរងផលប៉ះពាល់។',
      'success': 'បានផ្ញើរបាយការណ៍សត្វឈឺដោយជោគជ័យ។',
      'failed': 'មិនអាចផ្ញើរបាយការណ៍សត្វឈឺបានទេ។',
    },
  };

  String _getText(String key) {
    return _localizedValues[_languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode;
    _loadFlocks();
  }

  @override
  void didUpdateWidget(covariant SickReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      _languageCode = widget.languageCode;
    }
  }

  Future<void> _loadFlocks() async {
    try {
      final flocks = await _flockService.fetchFlocks();
      if (!mounted) return;
      setState(() {
        _flocks = flocks;
        _selectedFlockId = flocks.isNotEmpty ? flocks.first.flockId : null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport() async {
    final affectedCount = int.tryParse(_affectedCountController.text.trim());
    if (_selectedFlockId == null) {
      setState(() => _errorMessage = _getText('required_flock'));
      return;
    }
    if (affectedCount == null || affectedCount < 1) {
      setState(() => _errorMessage = _getText('required_count'));
      return;
    }
    if (_selectedSymptoms.isEmpty && _detailsController.text.trim().isEmpty) {
      setState(() => _errorMessage = _getText('observed_symptoms'));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Authentication token is missing.');
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/sick-reports'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'flockId': _selectedFlockId,
              'reportType': 'disease',
              'affectedCount': affectedCount,
              'symptoms': [
                ..._selectedSymptoms,
                if (_detailsController.text.trim().isNotEmpty)
                  _detailsController.text.trim(),
              ].join(', '),
              'reportDate': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        var serverMessage = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['message'] != null) {
            serverMessage = decoded['message'].toString();
          }
        } catch (_) {
          // Keep the raw response when the server does not return JSON.
        }
        throw Exception('HTTP ${response.statusCode}: $serverMessage');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getText('success'))));
      _selectedSymptoms.clear();
      _affectedCountController.clear();
      _detailsController.clear();
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = '${_getText('failed')} ${error.toString()}',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _toggleSymptom(String symptomKey) {
    setState(() {
      if (_selectedSymptoms.contains(symptomKey)) {
        _selectedSymptoms.remove(symptomKey);
      } else {
        _selectedSymptoms.add(symptomKey);
      }
    });
  }

  @override
  void dispose() {
    _affectedCountController.dispose();
    _detailsController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _getText('page_title'),
          style: const TextStyle(
            color: primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My sick reports',
            icon: const Icon(Icons.assignment_outlined, color: primaryGreen),
            onPressed: () => context.push('/my-sick-reports?lang=$_languageCode'),
          ),
          PopupMenuButton<String>(
            tooltip: 'Change language',
            icon: const Icon(Icons.language, color: primaryGreen),
            onSelected: (languageCode) {
              setState(() => _languageCode = languageCode);
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'en',
                checked: _languageCode == 'en',
                child: const Text('English'),
              ),
              CheckedPopupMenuItem(
                value: 'km',
                checked: _languageCode == 'km',
                child: const Text('ខ្មែរ'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Text(_getText('loading')))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    // Header Title & Subtitle
                    Text(
                      _getText('header_title'),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getText('header_subtitle'),
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Select Flock Dropdown
                    Text(
                      _getText('select_flock'),
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedFlockId,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: textDark,
                          ),
                          items: _flocks.map((flock) {
                            return DropdownMenuItem<int>(
                              value: flock.flockId,
                              child: Text(
                                '${flock.batchName} (${flock.birdCount} birds)',
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _selectedFlockId = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                    if (_flocks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _getText('no_flocks'),
                          style: const TextStyle(color: textMuted),
                        ),
                      ),
                    const SizedBox(height: 20),

                    Text(
                      _getText('affected_count'),
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _affectedCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: inputBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Observed Symptoms Section
                    Text(
                      _getText('observed_symptoms'),
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        _buildSymptomCard(
                          id: 'lethargy',
                          icon: Icons.sentiment_dissatisfied_outlined,
                          label: _getText('symptom_lethargy'),
                        ),
                        _buildSymptomCard(
                          id: 'respiratory',
                          icon: Icons.air_rounded,
                          label: _getText('symptom_respiratory'),
                        ),
                        _buildSymptomCard(
                          id: 'diarrhea',
                          icon: Icons.water_drop_outlined,
                          label: _getText('symptom_diarrhea'),
                        ),
                        _buildSymptomCard(
                          id: 'appetite',
                          icon: Icons.no_food_outlined,
                          label: _getText('symptom_appetite'),
                        ),
                        _buildSymptomCard(
                          id: 'mortality',
                          icon: Icons.warning_amber_rounded,
                          label: _getText('symptom_mortality'),
                        ),
                        _buildSymptomCard(
                          id: 'other',
                          icon: Icons.edit_note_rounded,
                          label: _getText('symptom_other'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Additional Details Textarea
                    Text(
                      _getText('additional_details'),
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _getText('details_placeholder'),
                        hintStyle: const TextStyle(
                          color: textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: cardBg,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting || _flocks.isEmpty
                            ? null
                            : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _getText('submit_btn'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildSymptomCard({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedSymptoms.contains(id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _toggleSymptom(id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen.withValues(alpha: 0.05) : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryGreen : inputBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? primaryGreen : textDark, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? primaryGreen : textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return FarmerBottomNavigation(
      currentIndex: 2,
      languageCode: _languageCode,
    );
  }
}
