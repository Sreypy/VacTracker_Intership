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
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF034418);
  static const Color greenLight = Color(0xFFEAF5EE);
  static const Color greenSoft = Color(0xFFF3F9F5);

  static const Color backgroundLight = Color(0xFFF7F9F8);
  static const Color cardBg = Colors.white;

  static const Color textDark = Color(0xFF10251A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF94A3B8);

  static const Color borderColor = Color(0xFFE2E8E5);

  static const Color warningBg = Color(0xFFFFF7E6);
  static const Color warningText = Color(0xFFB7791F);

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _errorMessage;

  Map<String, dynamic>? _report;

  // ============================================================
  // FORM
  // ============================================================

  final TextEditingController _diagnosisController = TextEditingController();

  final TextEditingController _adviceController = TextEditingController();

  String? _selectedAction;
  DateTime? _followUpDate;

  // ============================================================
  // LOCALIZATION
  // ============================================================

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Sick Report',
      'loading': 'Loading report...',
      'load_error': 'Could not load sick report.',
      'retry': 'Retry',

      'needs_review': 'Needs Review',
      'reviewed': 'Reviewed',

      'section_info': 'Report Overview',
      'label_flock': 'Flock',
      'label_farmer': 'Farmer',
      'label_farm': 'Farm',
      'label_problem': 'Problem',
      'label_affected': 'Affected Chickens',
      'label_date': 'Report Date',

      'label_symptoms': 'Symptoms',
      'label_description': "Farmer's Description",
      'label_photo': 'Photo',
      'label_no_photo': 'No photo uploaded',
      'view_photo': 'View Photo',

      'section_response': 'Veterinarian Response',
      'label_diagnosis': 'Diagnosis',
      'label_advice': 'Advice',
      'label_action': 'Recommended Action',

      'hint_diagnosis': 'Enter diagnosis...',
      'hint_advice': 'Enter advice for farmer...',

      'action_monitor': 'Monitor flock',
      'action_separate': 'Separate sick chickens',
      'action_treatment': 'Treatment',
      'action_vaccination': 'Vaccination',
      'action_other': 'Other',

      'label_followup': 'Follow-up Date',
      'select_date': 'Select date',

      'btn_send': 'Send Response',
      'btn_contact': 'Contact Farmer',

      'contact_farmer': 'Contact Farmer',
      'name': 'Name',
      'phone': 'Phone',
      'close': 'Close',

      'success': 'Response sent successfully!',
      'failed': 'Failed to send response.',
      'diagnosis_required': 'Please enter a diagnosis',

      'chickens': 'chickens',
    },

    'km': {
      'title': 'របាយការណ៍សត្វឈឺ',
      'loading': 'កំពុងផ្ទុករបាយការណ៍...',
      'load_error': 'មិនអាចផ្ទុករបាយការណ៍សត្វឈឺបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',

      'needs_review': 'ត្រូវការពិនិត្យ',
      'reviewed': 'បានពិនិត្យ',

      'section_info': 'ព័ត៌មានរបាយការណ៍',
      'label_flock': 'ហ្វូង',
      'label_farmer': 'កសិករ',
      'label_farm': 'កសិដ្ឋាន',
      'label_problem': 'បញ្ហា',
      'label_affected': 'សត្វរងផលប៉ះពាល់',
      'label_date': 'កាលបរិច្ឆេទរបាយការណ៍',

      'label_symptoms': 'រោគសញ្ញា',
      'label_description': 'ការពិពណ៌នាពីកសិករ',
      'label_photo': 'រូបភាព',
      'label_no_photo': 'មិនមានរូបភាព',
      'view_photo': 'មើលរូបភាព',

      'section_response': 'ការឆ្លើយតបរបស់ពេទ្យសត្វ',
      'label_diagnosis': 'រោគវិនិច្ឆ័យ',
      'label_advice': 'ការណែនាំ',
      'label_action': 'សកម្មភាពដែលបានណែនាំ',

      'hint_diagnosis': 'បញ្ចូលរោគវិនិច្ឆ័យ...',
      'hint_advice': 'បញ្ចូលការណែនាំសម្រាប់កសិករ...',

      'action_monitor': 'តាមដានហ្វូង',
      'action_separate': 'បំបែកសត្វឈឺ',
      'action_treatment': 'ការព្យាបាល',
      'action_vaccination': 'ការចាក់វ៉ាក់សាំង',
      'action_other': 'ផ្សេងៗ',

      'label_followup': 'កាលបរិច្ឆេទតាមដាន',
      'select_date': 'ជ្រើសរើសកាលបរិច្ឆេទ',

      'btn_send': 'ផ្ញើការឆ្លើយតប',
      'btn_contact': 'ទំនាក់ទំនងកសិករ',

      'contact_farmer': 'ទំនាក់ទំនងកសិករ',
      'name': 'ឈ្មោះ',
      'phone': 'លេខទូរស័ព្ទ',
      'close': 'បិទ',

      'success': 'ការឆ្លើយតបត្រូវបានផ្ញើដោយជោគជ័យ!',
      'failed': 'ការផ្ញើការឆ្លើយតបបរាជ័យ។',
      'diagnosis_required': 'សូមបញ្ចូលរោគវិនិច្ឆ័យ',

      'chickens': 'ក្បាល',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  bool get _isKhmer => widget.languageCode == 'km';

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/sick-reports/${widget.reportId}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> report = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        _report = report;
        _isLoading = false;

        if (report['vetDiagnosis']?.toString().isNotEmpty == true) {
          _diagnosisController.text = report['vetDiagnosis']?.toString() ?? '';
        } else if (report['vetNotes']?.toString().isNotEmpty == true) {
          _diagnosisController.text = report['vetNotes']?.toString() ?? '';
        }

        if (report['vetAdvice']?.toString().isNotEmpty == true) {
          _adviceController.text = report['vetAdvice']?.toString() ?? '';
        }

        final followUp = report['followUpDate'];

        if (followUp != null) {
          try {
            _followUpDate = DateTime.parse(followUp.toString());
          } catch (_) {}
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

  // ============================================================
  // SUBMIT RESPONSE
  // ============================================================

  Future<void> _submitResponse() async {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('diagnosis_required')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing.');
      }

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

      final response = await http
          .patch(
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
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (!mounted) return;

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
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: _buildAppBar(),

      bottomNavigationBar: _buildBottomNav(),

      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    final status = _report?['status']?.toString().toLowerCase();

    final isReviewed = status == 'reviewed';

    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      scrolledUnderElevation: 0,

      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: primaryGreen,
          size: 21,
        ),
      ),

      titleSpacing: 0,

      title: Text(
        _getText('title'),
        style: const TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: isReviewed ? greenLight : warningBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isReviewed
                    ? Icons.check_circle_outline_rounded
                    : Icons.access_time_rounded,
                size: 15,
                color: isReviewed ? primaryGreen : warningText,
              ),
              const SizedBox(width: 5),
              Text(
                isReviewed ? _getText('reviewed') : _getText('needs_review'),
                style: TextStyle(
                  color: isReviewed ? primaryGreen : warningText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCaseHeader(),

          const SizedBox(height: 24),

          _buildSectionHeader(
            _getText('section_info'),
            Icons.info_outline_rounded,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(),

          if (_hasSymptoms()) ...[
            const SizedBox(height: 24),

            _buildSectionHeader(
              _getText('label_symptoms'),
              Icons.warning_amber_rounded,
            ),

            const SizedBox(height: 12),

            _buildSymptomsCard(),
          ],

          if (_hasDescription()) ...[
            const SizedBox(height: 24),

            _buildSectionHeader(
              _getText('label_description'),
              Icons.notes_rounded,
            ),

            const SizedBox(height: 12),

            _buildDescriptionCard(),
          ],

          const SizedBox(height: 24),

          _buildSectionHeader(
            _getText('label_photo'),
            Icons.photo_camera_outlined,
          ),

          const SizedBox(height: 12),

          _buildPhotoCard(),

          const SizedBox(height: 28),

          _buildResponseHeader(),

          const SizedBox(height: 12),

          _buildResponseForm(),

          const SizedBox(height: 24),

          _buildActionButtons(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // CASE HEADER
  // ============================================================

  Widget _buildCaseHeader() {
    final flock = _report?['flock'] as Map<String, dynamic>? ?? {};

    final batchName = flock['batch_name']?.toString() ?? 'Unknown';

    final affected = _report?['affectedCount']?.toString() ?? '0';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$affected ${_getText('chickens')} affected',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: greenLight,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, color: primaryGreen, size: 18),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    final flock = _report?['flock'] as Map<String, dynamic>? ?? {};

    final reporter = _report?['reporter'] as Map<String, dynamic>? ?? {};

    final batchName = flock['batch_name']?.toString() ?? 'Unknown';

    final farmerName = reporter['name']?.toString() ?? 'Unknown';

    final farmName = flock['farm_name']?.toString() ?? 'Unknown';

    final reportType = _report?['reportType']?.toString() ?? 'disease';

    final affectedCount = _report?['affectedCount']?.toString() ?? '0';

    final reportDate = _report?['reportDate']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: _cardDecoration(),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.home_work_outlined,
                  _getText('label_flock'),
                  batchName,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.person_outline_rounded,
                  _getText('label_farmer'),
                  farmerName,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(height: 1, color: borderColor.withValues(alpha: 0.7)),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.agriculture_outlined,
                  _getText('label_farm'),
                  farmName,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.warning_amber_outlined,
                  _getText('label_problem'),
                  reportType.toUpperCase(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(height: 1, color: borderColor.withValues(alpha: 0.7)),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.pets_outlined,
                  _getText('label_affected'),
                  '$affectedCount ${_getText('chickens')}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_outlined,
                  _getText('label_date'),
                  _formatDate(reportDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: greenSoft,
            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(icon, size: 17, color: primaryGreen),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SYMPTOMS
  // ============================================================

  Widget _buildSymptomsCard() {
    final symptoms = _report?['symptoms']?.toString() ?? '';

    final symptomList = symptoms
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: _cardDecoration(),

      child: Wrap(
        spacing: 8,
        runSpacing: 8,

        children: symptomList.map((symptom) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(
              color: greenSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGreen.withValues(alpha: 0.12)),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 7, color: primaryGreen),

                const SizedBox(width: 7),

                Text(
                  symptom,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionCard() {
    final description =
        _report?['description']?.toString() ??
        _report?['farmerDescription']?.toString() ??
        '';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: _cardDecoration(),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 55,

            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              description.isNotEmpty ? '"$description"' : '—',
              style: TextStyle(
                color: description.isNotEmpty ? textDark : textMuted,
                fontSize: 14,
                height: 1.5,
                fontStyle: description.isNotEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO
  // ============================================================

  Widget _buildPhotoCard() {
    final photoUrl = _report?['photoUrl']?.toString();

    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return GestureDetector(
      onTap: hasPhoto ? () => _showPhoto(photoUrl) : null,

      child: Container(
        width: double.infinity,
        height: 210,

        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),

        clipBehavior: Clip.antiAlias,

        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photoUrl,
                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      return _buildNoPhotoPlaceholder();
                    },
                  ),

                  Positioned(
                    right: 12,
                    bottom: 12,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _getText('view_photo'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildNoPhotoPlaceholder(),
      ),
    );
  }

  // ============================================================
  // NO PHOTO
  // ============================================================

  Widget _buildNoPhotoPlaceholder() {
    return Container(
      color: greenSoft,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),

            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 27,
              color: textLight,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _getText('label_no_photo'),
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO VIEWER
  // ============================================================

  void _showPhoto(String photoUrl) {
    showDialog(
      context: context,

      barrierColor: Colors.black87,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),

          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: InteractiveViewer(
                  child: Image.network(photoUrl, fit: BoxFit.contain),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,

                child: IconButton(
                  onPressed: () => Navigator.pop(context),

                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                  ),

                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // RESPONSE HEADER
  // ============================================================

  Widget _buildResponseHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: greenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.08)),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.medical_services_outlined,
              color: primaryGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  _getText('section_response'),
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _isKhmer
                      ? 'ផ្តល់ការវាយតម្លៃ និងការណែនាំដល់កសិករ'
                      : 'Provide your assessment and guidance to the farmer.',
                  style: TextStyle(
                    color: primaryGreen.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESPONSE FORM
  // ============================================================

  Widget _buildResponseForm() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(_getText('label_diagnosis'), required: true),

          const SizedBox(height: 8),

          _buildTextField(
            controller: _diagnosisController,
            hintText: _getText('hint_diagnosis'),
            maxLines: 4,
          ),

          const SizedBox(height: 20),

          _buildFieldLabel(_getText('label_advice')),

          const SizedBox(height: 8),

          _buildTextField(
            controller: _adviceController,
            hintText: _getText('hint_advice'),
            maxLines: 4,
          ),

          const SizedBox(height: 22),

          _buildFieldLabel(_getText('label_action')),

          const SizedBox(height: 10),

          ..._buildActionOptions(),

          const SizedBox(height: 18),

          _buildFieldLabel(_getText('label_followup')),

          const SizedBox(height: 8),

          _buildDatePicker(),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (required) ...[
          const SizedBox(width: 3),

          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      style: const TextStyle(color: textDark, fontSize: 14, height: 1.4),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: const TextStyle(color: textLight, fontSize: 13),

        filled: true,
        fillColor: backgroundLight,

        contentPadding: const EdgeInsets.all(14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION OPTIONS
  // ============================================================

  List<Widget> _buildActionOptions() {
    final actions = [
      _getText('action_monitor'),
      _getText('action_separate'),
      _getText('action_treatment'),
      _getText('action_vaccination'),
      _getText('action_other'),
    ];

    final icons = [
      Icons.visibility_outlined,
      Icons.sync_alt_rounded,
      Icons.medication_outlined,
      Icons.vaccines_outlined,
      Icons.more_horiz_rounded,
    ];

    return List.generate(actions.length, (index) {
      final action = actions[index];

      final isSelected = _selectedAction == action;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: () {
            setState(() {
              _selectedAction = isSelected ? null : action;
            });
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),

            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),

            decoration: BoxDecoration(
              color: isSelected ? greenSoft : backgroundLight,

              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: isSelected ? primaryGreen : borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,

                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),

                  child: Icon(
                    icons[index],
                    size: 18,
                    color: isSelected ? primaryGreen : textMuted,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    action,
                    style: TextStyle(
                      color: isSelected ? primaryGreen : textDark,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),

                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 21,
                  color: isSelected ? primaryGreen : textLight,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Widget _buildDatePicker() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: _pickFollowUpDate,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        decoration: BoxDecoration(
          color: backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),

        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),

              child: const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: primaryGreen,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Text(
                _followUpDate != null
                    ? _formatShortDate(_followUpDate!)
                    : _getText('select_date'),

                style: TextStyle(
                  color: _followUpDate != null ? textDark : textMuted,
                  fontSize: 13,
                  fontWeight: _followUpDate != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: textLight, size: 21),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),

      firstDate: DateTime.now(),

      lastDate: DateTime.now().add(const Duration(days: 90)),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryGreen),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,

          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitResponse,

            icon: _isSubmitting
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 19),

            label: Text(_isSubmitting ? '...' : _getText('btn_send')),

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 50,

          child: OutlinedButton.icon(
            onPressed: _showContactFarmerDialog,

            icon: const Icon(Icons.phone_outlined, size: 19),

            label: Text(_getText('btn_contact')),

            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,

              side: const BorderSide(color: primaryGreen, width: 1.3),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTACT FARMER
  // ============================================================

  void _showContactFarmerDialog() {
    final reporter = _report?['reporter'] as Map<String, dynamic>? ?? {};

    final farmerName = reporter['name']?.toString() ?? '—';

    final farmerPhone = reporter['phone']?.toString() ?? '';

    showDialog(
      context: context,

      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color: greenLight,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        _getText('contact_farmer'),
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.pop(context),

                      icon: const Icon(Icons.close_rounded, color: textMuted),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildContactInfo(
                  _getText('name'),
                  farmerName,
                  Icons.person_outline_rounded,
                ),

                const SizedBox(height: 14),

                _buildContactInfo(
                  _getText('phone'),
                  farmerPhone.isNotEmpty ? farmerPhone : '—',
                  Icons.phone_outlined,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: const BorderSide(color: primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(_getText('close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONTACT INFO
  // ============================================================

  Widget _buildContactInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: greenSoft,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, size: 18, color: primaryGreen),
        ),

        const SizedBox(width: 11),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(top: BorderSide(color: borderColor, width: 1)),
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
        unselectedItemColor: textLight,

        showSelectedLabels: false,
        showUnselectedLabels: false,

        elevation: 0,

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

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: primaryGreen,
            ),
          ),

          SizedBox(height: 14),

          Text(
            'Loading report...',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: greenSoft,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_outlined,
                size: 32,
                color: textMuted,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _errorMessage ?? _getText('load_error'),

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: textDark,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: _loadReport,

              icon: const Icon(Icons.refresh_rounded, size: 18),

              label: Text(_getText('retry')),

              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,

                side: const BorderSide(color: primaryGreen),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardBg,

      borderRadius: BorderRadius.circular(16),

      border: Border.all(color: borderColor),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  bool _hasSymptoms() {
    final symptoms = _report?['symptoms']?.toString() ?? '';

    return symptoms.trim().isNotEmpty;
  }

  bool _hasDescription() {
    final description =
        _report?['description']?.toString() ??
        _report?['farmerDescription']?.toString() ??
        '';

    return description.trim().isNotEmpty;
  }

  String _formatDate(String value) {
    if (value.isEmpty) {
      return '—';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')} '
          '${_getMonthName(date.month)} '
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
}
