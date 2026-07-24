import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/config/api_config.dart';

class FarmerProfilePage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'

  const FarmerProfilePage({super.key, required this.languageCode});

  @override
  State<FarmerProfilePage> createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  int _currentIndex = 4; // Profile tab active

  // Backend User Profile Data State
  String _userName = '...';
  String _userPhone = '...';
  String _userRole = '...';
  bool _isLoadingProfile = true;

  // Notification Toggle States
  bool _vaccinationReminders = true;
  bool _sickReportUpdates = true;
  late String _currentLang;

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color badgeGreenBg = Color(0xFFD1E7DD);
  static const Color alertRed = Color(0xFFC5221F);

  // Localized Dictionary
  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'app_bar_title': 'VacTracker',
      // Preferences Section
      'sec_preferences': 'PREFERENCES',
      'lbl_language': 'Language',
      'sub_language': 'Khmer / English',

      // Notifications Section
      'sec_notifications': 'NOTIFICATIONS',
      'lbl_vac_reminders': 'Vaccination Reminders',
      'sub_vac_reminders': 'Alerts for upcoming shots',
      'lbl_sick_reports': 'Sick Report Updates',
      'sub_sick_reports': 'Status of reported cases',

      // App Info Section
      'sec_app_info': 'APP INFO',
      'lbl_terms': 'Terms of Use',
      'lbl_version': 'App Version',
      'val_version': 'v2.4.0-stable',

      // Actions
      'btn_logout': 'Logout',
    },
    'km': {
      'app_bar_title': 'VacTracker',
      // Preferences Section
      'sec_preferences': 'ការកំណត់',
      'lbl_language': 'ភាសា',
      'sub_language': 'ខ្មែរ / អង់គ្លេស',

      // Notifications Section
      'sec_notifications': 'ការជូនដំណឹង',
      'lbl_vac_reminders': 'ការរំលឹកការចាក់វ៉ាក់សាំង',
      'sub_vac_reminders': 'ការជូនដំណឹងសម្រាប់កាលវិភាគចាក់',
      'lbl_sick_reports': 'បច្ចុប្បន្នភាពរបាយការណ៍ជំងឺ',
      'sub_sick_reports': 'ស្ថានភាពនៃករណីដែលបានរាយការណ៍',

      // App Info Section
      'sec_app_info': 'ព័ត៌មានកម្មវិធី',
      'lbl_terms': 'លក្ខខណ្ឌនៃការប្រើប្រាស់',
      'lbl_version': 'កំណែកម្មវិធី',
      'val_version': 'v2.4.0-stable',

      // Actions
      'btn_logout': 'ចាកចេញ',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    _loadStoredUserName();
    _fetchUserProfile();
  }

  /// Fetch User Profile data from Backend API
  Future<void> _loadStoredUserName() async {
    final storedName = await StorageService.getName();
    if (!mounted) return;
    setState(() {
      if (storedName != null && storedName.isNotEmpty) {
        _userName = storedName;
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        // No auth token; use stored name or fallback
        _useFallbackProfile();
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/users/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userName = data['name'] ?? _userName;
            _userPhone = data['phone'] ?? _userPhone;
            _userRole = data['role'] ?? _userRole;
            _isLoadingProfile = false;
          });
        }

        // Persist minimal user info for other screens
        await StorageService.saveUser(data);
      } else {
        _useFallbackProfile();
      }
    } catch (e) {
      _useFallbackProfile();
    }
  }

  void _useFallbackProfile() {
    if (mounted) {
      setState(() {
        _userName = 'Sovann Makara';
        _userPhone = '+855 12 345 678';
        _userRole = 'Lead Farmer';
        _isLoadingProfile = false;
      });
    }
  }

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: textGreyLight,
            child: Icon(Icons.person, color: brandDarkGreen, size: 20),
          ),
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
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: brandDarkGreen,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // User Profile Top Card (Connected to Backend)
              _buildProfileHeaderCard(),

              const SizedBox(height: 20),

              // Preferences Section Card
              _buildSectionWrapper(
                title: _getText('sec_preferences'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.translate_rounded,
                            color: brandDarkGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getText('lbl_language'),
                                style: const TextStyle(
                                  color: textDarkBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getText('sub_language'),
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildLanguageToggle(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notifications Section Card
              _buildSectionWrapper(
                title: _getText('sec_notifications'),
                child: Column(
                  children: [
                    // Vaccination Reminders
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: brandDarkGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getText('lbl_vac_reminders'),
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getText('sub_vac_reminders'),
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _vaccinationReminders,
                            activeThumbColor: brandDarkGreen,
                            activeTrackColor: brandDarkGreen.withValues(
                              alpha: 0.2,
                            ),
                            onChanged: (val) {
                              setState(() => _vaccinationReminders = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: textGreyLight),

                    // Sick Report Updates
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            color: brandDarkGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getText('lbl_sick_reports'),
                                  style: const TextStyle(
                                    color: textDarkBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getText('sub_sick_reports'),
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _sickReportUpdates,
                            activeThumbColor: brandDarkGreen,
                            activeTrackColor: brandDarkGreen.withValues(
                              alpha: 0.2,
                            ),
                            onChanged: (val) {
                              setState(() => _sickReportUpdates = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App Info Section Card
              _buildSectionWrapper(
                title: _getText('sec_app_info'),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              color: brandDarkGreen,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _getText('lbl_terms'),
                                style: const TextStyle(
                                  color: textDarkBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: textGrey,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: textGreyLight),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: brandDarkGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _getText('lbl_version'),
                              style: const TextStyle(
                                color: textDarkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _getText('val_version'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go('/auth-choice/farmer/$_currentLang');
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: alertRed,
                    size: 20,
                  ),
                  label: Text(
                    _getText('btn_logout'),
                    style: const TextStyle(
                      color: alertRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: alertRed, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  // Profile Header Card Component with Backend Loading Logic
  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: _isLoadingProfile
          ? const SizedBox(
              height: 72,
              child: Center(
                child: CircularProgressIndicator(color: brandDarkGreen),
              ),
            )
          : Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA2F39B).withValues(alpha: 0.4),
                        border: Border.all(
                          color: const Color(0xFFA2F39B),
                          width: 3,
                        ),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: brandDarkGreen,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: brandDarkGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: brandDarkGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userPhone,
                        style: const TextStyle(color: textGrey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userRole,
                          style: const TextStyle(
                            color: brandDarkGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionWrapper({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: brandHeaderGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isKhmer = _currentLang == 'km';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _currentLang = 'km';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isKhmer ? brandDarkGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'KH',
                style: TextStyle(
                  color: isKhmer ? Colors.white : textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentLang = 'en';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: !isKhmer ? brandDarkGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'English',
                style: TextStyle(
                  color: !isKhmer ? Colors.white : textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
          } else if (index == 1) {
            context.go('/log-vaccination-step1/$_currentLang');
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.vaccines_outlined, size: 26),
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
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: brandDarkGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: brandDarkGreen, size: 24),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
