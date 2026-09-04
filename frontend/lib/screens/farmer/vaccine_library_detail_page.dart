import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/services/vaccine_library_service.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';

class VaccineLibraryDetailPage extends StatefulWidget {
  final String articleId;
  final String languageCode;

  const VaccineLibraryDetailPage({
    super.key,
    required this.articleId,
    this.languageCode = 'km',
  });

  @override
  State<VaccineLibraryDetailPage> createState() =>
      _VaccineLibraryDetailPageState();
}

class _VaccineLibraryDetailPageState extends State<VaccineLibraryDetailPage> {
  late String _currentLang;
  String _profileName = '';
  String _profileImageUrl = '';
  bool _isLoading = true;
  Map<String, dynamic>? _article;

  final VaccineLibraryService _libraryService = VaccineLibraryService();

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandMediumGreen = Color(0xFF056525);
  static const Color textDarkBlue = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF475569);
  static const Color textGreyLight = Color(0xFFE2E8F0);

  // Localization Dictionary
  final Map<String, Map<String, String>> _localizedValues = const {
    'km': {
      'page_title': 'លម្អិតវ៉ាក់សាំង',
      'lbl_disease': 'ជំងឺការពារ',
      'lbl_what_is_disease': 'អ្វីជាជំងឺនេះ?',
      'lbl_why_important': 'ហេតុអ្វីវ៉ាក់សាំងនេះសំខាន់?',
      'lbl_usage': 'វិធីប្រើប្រាស់ទូទៅ',
      'lbl_precautions': 'ការប្រុងប្រយ័ត្នសំខាន់',
      'lbl_other_info': 'ព័ត៌មានបន្ថែម',
      'btn_log_vaccine': 'កត់ត្រាវ៉ាក់សាំងនេះ',
      'err_load': 'មិនអាចទាញយកព័ត៌មានបានទេ',
      'lbl_retry': 'ព្យាយាមម្ដងទៀត',
    },
    'en': {
      'page_title': 'Vaccine Details',
      'lbl_disease': 'Target Disease',
      'lbl_what_is_disease': 'What is this disease?',
      'lbl_why_important': 'Why is this vaccine important?',
      'lbl_usage': 'How is it generally used?',
      'lbl_precautions': 'Important Precautions',
      'lbl_other_info': 'Additional Information',
      'btn_log_vaccine': 'Log This Vaccine',
      'err_load': 'Failed to load information',
      'lbl_retry': 'Retry',
    },
  };

  Future<void> _loadProfile() async {
    final storedName = await StorageService.getName();
    final storedImageUrl = await StorageService.getProfileImageUrl();
    if (!mounted) return;
    setState(() {
      if (storedName?.trim().isNotEmpty == true) {
        _profileName = storedName!.trim();
      }
      if (storedImageUrl?.trim().isNotEmpty == true) {
        _profileImageUrl = storedImageUrl!.trim();
      }
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200 || !mounted) return;
      final profile = jsonDecode(response.body) as Map<String, dynamic>;
      final name = (profile['name'] ?? '').toString().trim();
      final imageUrl =
          (profile['profile_image_url'] ??
                  profile['avatar_url'] ??
                  profile['profile_image'] ??
                  profile['image_url'] ??
                  profile['photo_url'] ??
                  '')
              .toString()
              .trim();
      setState(() {
        if (name.isNotEmpty) _profileName = name;
        if (imageUrl.isNotEmpty) _profileImageUrl = imageUrl;
      });
      await StorageService.saveUser(profile);
    } catch (_) {
      // Stored profile data or initials remain available as a fallback.
    }
  }

  Widget _buildProfileAvatar() {
    final initial = _profileName.trim().isNotEmpty
        ? _profileName.trim()[0].toUpperCase()
        : 'U';
    final bool hasImage = _profileImageUrl.isNotEmpty;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: brandDarkGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              _profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: brandDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _currentLang = widget.languageCode;
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    setState(() => _isLoading = true);

    try {
      final article = await _libraryService.fetchArticleById(
        int.parse(widget.articleId),
      );

      if (mounted) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ??
        _localizedValues['km']![key]!;
  }

  String _getField(String enKey, String kmKey) {
    if (_article == null) return '';
    return _currentLang == 'km'
        ? (_article![kmKey]?.toString() ?? '')
        : (_article![enKey]?.toString() ?? '');
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: brandDarkGreen,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 16,
        title: const Text(
          'VacTracker',
          style: TextStyle(
            color: brandDarkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationHeaderButton(
            languageCode: _currentLang,
            color: brandDarkGreen,
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/farmer-profile/$_currentLang'),
            icon: _buildProfileAvatar(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: brandDarkGreen),
              )
            : _article == null
            ? _buildErrorView()
            : _buildContentView(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_article != null && !_isLoading) _buildBottomActionBar(),
          FarmerBottomNavigation(
            currentIndex: 3,
            languageCode: _currentLang,
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner Header
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Disease Identity Section
          _buildSectionCard(
            icon: Icons.shield_outlined,
            title: _getText('lbl_disease'),
            content: _getField('disease_en', 'disease_km'),
          ),
          const SizedBox(height: 12),

          // Disease Description
          _buildSectionCard(
            icon: Icons.info_outline_rounded,
            title: _getText('lbl_what_is_disease'),
            content: _getField(
              'disease_description_en',
              'disease_description_km',
            ),
          ),
          const SizedBox(height: 12),

          // Vaccine Importance
          _buildSectionCard(
            icon: Icons.verified_outlined,
            title: _getText('lbl_why_important'),
            content: _getField('why_important_en', 'why_important_km'),
          ),
          const SizedBox(height: 12),

          // Administration Guidance
          _buildSectionCard(
            icon: Icons.medication_liquid_outlined,
            title: _getText('lbl_usage'),
            content: _getField('usage_en', 'usage_km'),
          ),
          const SizedBox(height: 12),

          // Critical Precautions Banner
          _buildSectionCard(
            icon: Icons.warning_amber_rounded,
            title: _getText('lbl_precautions'),
            content: _getField('precautions_en', 'precautions_km'),
            isWarning: true,
          ),

          // Optional Extra Details
          if (_getField('other_info_en', 'other_info_km').isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSectionCard(
              icon: Icons.lightbulb_outline_rounded,
              title: _getText('lbl_other_info'),
              content: _getField('other_info_en', 'other_info_km'),
            ),
          ],

          // Extra spacing so content is clear of the bottom bar
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final name = _getField('name_en', 'name_km');
    final description = _getField('description_en', 'description_km');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [brandDarkGreen, brandMediumGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandDarkGreen.withAlpha(40),
            blurRadius: 12,
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
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.vaccines,
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
                      name.isNotEmpty ? name : '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentLang == 'km'
                            ? 'បណ្ណាល័យវ៉ាក់សាំង'
                            : 'Vaccine Reference',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    final primaryColor = isWarning ? const Color(0xFFB45309) : brandDarkGreen;
    final iconBgColor = isWarning
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFE8F5E9);
    final cardBorder = isWarning ? const Color(0xFFFDE68A) : textGreyLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: isWarning
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isWarning ? const Color(0xFF92400E) : textDarkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: isWarning ? const Color(0xFF78350F) : textGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            context.push('/log-vaccination-step1/$_currentLang');
          },
          icon: const Icon(Icons.edit_calendar_rounded, size: 20),
          label: Text(
            _getText('btn_log_vaccine'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: brandDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _getText('err_load'),
              style: const TextStyle(color: textGrey, fontSize: 15),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _fetchArticle,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_getText('lbl_retry')),
              style: OutlinedButton.styleFrom(
                foregroundColor: brandDarkGreen,
                side: const BorderSide(color: brandDarkGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
