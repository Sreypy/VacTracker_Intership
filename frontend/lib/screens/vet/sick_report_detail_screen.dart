import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class VetSickReportDetailScreen extends StatefulWidget {
  final String reportId;
  final String languageCode;

  const VetSickReportDetailScreen({
    super.key,
    required this.reportId,
    this.languageCode = 'en',
  });

  @override
  State<VetSickReportDetailScreen> createState() =>
      _VetSickReportDetailScreenState();
}

class _VetSickReportDetailScreenState extends State<VetSickReportDetailScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // State
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _report;

  // Form Controllers
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  String? _selectedAction;
  DateTime? _followUpDate;

  // Localization
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Sick Report',
      'loading': 'Loading report...',
      'load_error': 'Could not load sick report.',
      'retry': 'Retry',
      'section_info': 'Report Information',
      'label_flock': 'Flock',
      'label_farmer': 'Farmer',
      'label_farm': 'Farm',
      'label_problem': 'Problem',
      'label_affected': 'Affected Chickens',
      'label_date': 'Report Date',
      'label_symptoms': 'Symptoms',
      'label_description': 'Farmer Description',
      'label_photo': 'Photo',
      'label_no_photo': 'No photo uploaded',
      'section_response': 'Veterinarian Response',
      'label_diagnosis': 'Diagnosis',
      'label_advice': 'Advice',
      'label_action': 'Recommended Action',
      'action_monitor': 'Monitor flock',
      'action_separate': 'Separate sick chickens',
      'action_treatment': 'Treatment',
      'action_vaccination': 'Vaccination',
      'action_other': 'Other',
      'label_followup': 'Follow-up Date',
      'btn_send': 'Send Response',
      'btn_contact': 'Contact Farmer',
      'btn_back': 'Back',
      'success': 'Response sent successfully!',
      'failed': 'Failed to send response.',
    },
    'km': {
      'title': 'របាយការណ៍សត្វឈឺ',
      'loading': 'កំពុងផ្ទុករបាយការណ៍...',
      'load_error': 'មិនអាចផ្ទុករបាយការណ៍សត្វឈឺបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
      'section_info': 'ព័ត៌មានរបាយការណ៍',
      'label_flock': 'ហ្វូង',
      'label_farmer': 'កសិករ',
      'label_farm': 'កសិដ្ឋាន',
      'label_problem': 'បញ្ហា',
      'label_affected': 'សត្វរងផលប៉ះពាល់',
      'label_date': 'កាលបរិច្ឆេទរបាយការណ៍',
      'label_symptoms': 'រោគសញ្ញា',
      'label_description': 'ការពណ័នាំពីកសិករ',
      'label_photo': 'រូបភាព',
      'label_no_photo': 'មិនមានរូបភាព',
      'section_response': 'ការឆ្លើយតបរបស់គ្រូពេទ្យសត្វ',
      'label_diagnosis': 'ការណែនាំរោគវិនិច្ឆ័យ',
      'label_advice': 'ការណែនាំ',
      'label_action': 'សកម្មភាពដែលផ្តល់អនុសាយ',
      'action_monitor': 'ត្រមត្រាការអន្តរាគមន៍',
      'action_separate': 'ខ្វះសត្វឈឺដោយឡែក',
      'action_treatment': 'ការព្យាបាល',
      'action_vaccination': 'ការចាក់វ៉ាក់សាំង',
      'action_other': 'ផ្សេងៗ',
      'label_followup': 'កាលបរិច្ឆេទតាមដានបន្ទាប់',
      'btn_send': 'ផ្ញើការឆ្លើយតប',
      'btn_contact': 'ទំនាក់ទំនងកសិករ',
      'btn_back': 'ត្រឡប់ក្រោយ',
      'success': 'ការឆ្លើយតបត្រូវបានផ្ញើដោយជោគជ័យ!',
      'failed': 'ការផ្ញើការឆ្លើយតបបរាជ័យ។',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Authentication token is missing.');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/sick-reports/${widget.reportId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> report = jsonDecode(response.body);
      
      if (!mounted) return;
      setState(() {
        _report = report;
        _isLoading = false;
        
        // Pre-fill form if vet notes exist
        if (report['vetNotes']?.toString().isNotEmpty == true) {
          _diagnosisController.text = report['vetNotes']?.toString() ?? '';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${_getText('load_error')} ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitResponse() async {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a diagnosis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Authentication token is missing.');

      // Map selected action to backend enum value
      String? actionValue;
      if (_selectedAction != null) {
        final actionMap = {
          _getText('action_monitor'): 'monitor',
          _getText('action_separate'): 'separate',
          _getText('action_treatment'): 'treatment',
          _getText('action_vaccination'): 'vaccination',
          _getText('action_other'): 'other',
        };
        actionValue = actionMap[_selectedAction];
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/sick-reports/${widget.reportId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vetDiagnosis': _diagnosisController.text.trim(),
          'vetAdvice': _adviceController.text.trim(),
          'recommendedAction': actionValue,
          'followUpDate': _followUpDate?.toIso8601String(),
          'status': 'reviewed',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (!mounted) return;

      // Navigate to Response Sent confirmation screen
      final reporter = _report?['reporter'] as Map<String, dynamic>? ?? {};
      final farmerName = reporter['name']?.toString() ?? 'the farmer';

      context.pushReplacement(
        '/vet-response-sent/${widget.reportId}?lang=${widget.languageCode}',
        extra: {
          'farmerName': farmerName,
          'diagnosis': _diagnosisController.text.trim(),
          'advice': _adviceController.text.trim(),
          'followUpDate': _followUpDate,
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getText('failed')} ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      bottomNavigationBar: _buildBottomNav(),
      body: _isLoading
          ? Center(child: Text(_getText('loading')))
          : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Information Section
                      _buildSectionHeader(_getText('section_info')),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                      const SizedBox(height: 24),

                      // Symptoms Section
                      if (_report?['symptoms']?.toString().isNotEmpty == true) ...[
                        _buildSectionHeader(_getText('label_symptoms')),
                        const SizedBox(height: 12),
                        _buildSymptomsCard(),
                        const SizedBox(height: 24),
                      ],

                      // Farmer Description
                      if (_report?['symptoms']?.toString().isNotEmpty == true) ...[
                        _buildSectionHeader(_getText('label_description')),
                        const SizedBox(height: 12),
                        _buildDescriptionCard(),
                        const SizedBox(height: 24),
                      ],

                      // Photo Section
                      _buildSectionHeader(_getText('label_photo')),
                      const SizedBox(height: 12),
                      _buildPhotoCard(),
                      const SizedBox(height: 24),

                      // Vet Response Section
                      _buildSectionHeader(_getText('section_response')),
                      const SizedBox(height: 16),
                      _buildResponseForm(),
                      const SizedBox(height: 32),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitResponse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
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
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _getText('btn_send'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Contact farmer using phone from report data
                            final reporter = _report?['reporter'] as Map<String, dynamic>? ?? {};
                            final farmerName = reporter['name']?.toString() ?? 'the farmer';
                            final farmerPhone = reporter['phone']?.toString() ?? '';
                            
                            showDialog(
                              context: context,
                              builder: (context) {
                                final isKhmer = widget.languageCode == 'km';
                                return AlertDialog(
                                  title: Text(
                                    isKhmer ? 'ទំនាក់ទំនងកសិករ' : 'Contact Farmer',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isKhmer ? 'ឈ្មោះ៖' : 'Name:',
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        farmerName,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isKhmer ? 'លេខទូរស័ព្ទ៖' : 'Phone:',
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        farmerPhone.isNotEmpty ? farmerPhone : '—',
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        isKhmer ? 'បិទ' : 'Close',
                                        style: const TextStyle(color: primaryGreen),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryGreen, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _getText('btn_contact'),
                            style: const TextStyle(
                              color: primaryGreen,
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
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: inputBorder, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/vet-dashboard?lang=${widget.languageCode}');
          } else if (index == 1) {
            context.go('/vet-reports?lang=${widget.languageCode}');
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard() {
    final flock = _report?['flock'] as Map<String, dynamic>? ?? {};
    final reporter = _report?['reporter'] as Map<String, dynamic>? ?? {};
    final batchName = flock['batch_name']?.toString() ?? 'Unknown';
    final farmerName = reporter['name']?.toString() ?? 'Unknown';
    final farmName = flock['farm_name']?.toString() ?? 'Unknown';
    final reportType = _report?['reportType']?.toString() ?? 'disease';
    final affectedCount = _report?['affectedCount']?.toString() ?? '0';
    final reportDate = _report?['reportDate']?.toString() ?? '';

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.home_work_outlined, _getText('label_flock'), batchName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outlined, _getText('label_farmer'), farmerName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.agriculture_outlined, _getText('label_farm'), farmName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.warning_amber_outlined, _getText('label_problem'), reportType.toUpperCase()),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.pets_outlined, _getText('label_affected'), '$affectedCount chickens'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined, _getText('label_date'), formattedDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsCard() {
    final symptoms = _report?['symptoms']?.toString() ?? '';
    final symptomList = symptoms.split(',').map((s) => s.trim()).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...symptomList.map((symptom) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: primaryGreen),
                const SizedBox(width: 12),
                Text(
                  symptom,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = _report?['symptoms']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: Text(
        description.isNotEmpty ? '"$description"' : _getText('label_no_photo'),
        style: TextStyle(
          color: textDark,
          fontSize: 14,
          fontStyle: description.isNotEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    final photoUrl = _report?['photoUrl']?.toString();

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: photoUrl != null && photoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildNoPhotoPlaceholder();
                },
              ),
            )
          : _buildNoPhotoPlaceholder(),
    );
  }

  Widget _buildNoPhotoPlaceholder() {
    return Container(
      color: backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 64, color: textMuted),
          const SizedBox(height: 12),
          Text(
            _getText('label_no_photo'),
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis
          Text(
            _getText('label_diagnosis'),
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _diagnosisController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter diagnosis...',
              hintStyle: TextStyle(color: textMuted, fontSize: 14),
              filled: true,
              fillColor: backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Advice
          Text(
            _getText('label_advice'),
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _adviceController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter advice for farmer...',
              hintStyle: TextStyle(color: textMuted, fontSize: 14),
              filled: true,
              fillColor: backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recommended Action
          Text(
            _getText('label_action'),
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildActionOptions(),
          const SizedBox(height: 20),

          // Follow-up Date
          Text(
            _getText('label_followup'),
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) {
                setState(() => _followUpDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: inputBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: textMuted),
                  const SizedBox(width: 12),
                  Text(
                    _followUpDate != null
                        ? '${_followUpDate!.day.toString().padLeft(2, '0')}/${_followUpDate!.month.toString().padLeft(2, '0')}/${_followUpDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: _followUpDate != null ? textDark : textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionOptions() {
    final actions = [
      _getText('action_monitor'),
      _getText('action_separate'),
      _getText('action_treatment'),
      _getText('action_vaccination'),
      _getText('action_other'),
    ];

    return actions.map((action) {
      final isSelected = _selectedAction == action;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedAction = isSelected ? null : action;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen.withValues(alpha: 0.05) : cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryGreen : inputBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? primaryGreen : textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  action,
                  style: TextStyle(
                    color: isSelected ? primaryGreen : textDark,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
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
            onPressed: _loadReport,
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _adviceController.dispose();
    super.dispose();
  }
}