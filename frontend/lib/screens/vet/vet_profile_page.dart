import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/services/auth_service.dart';

class VetProfileScreen extends StatefulWidget {
  final String currentLanguage; // 'en' or 'km'
  final ValueChanged<String>? onLanguageChanged;

  const VetProfileScreen({
    super.key,
    this.currentLanguage = 'en',
    this.onLanguageChanged,
  });

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color cardHeaderBg = Color(0xFFF1F5F9);

  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);

  static const Color badgeVerifiedBg = Color(0xFFDCFCE7);
  static const Color badgeVerifiedText = Color(0xFF15803D);

  static const Color logoutBg = Color(0xFFFEE2E2);
  static const Color logoutText = Color(0xFFDC2626);

  // State Variables
  late String _selectedLanguage;
  bool _newSickReportsEnabled = true;
  bool _clientOverdueAlertsEnabled = true;
  String? _vetShareLink;

  // Profile Data
  Map<String, dynamic>? _profileData;
  bool _isLoadingProfile = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoadingProfile = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final profile = await authService.getProfile();

      setState(() {
        _profileData = profile;
        _vetShareLink = profile['share_code'] ?? 'FG-VET-SOKHA-2024';
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProfile = false;
        _vetShareLink = 'FG-VET-SOKHA-2024';
      });
    }
  }

  void _toggleLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(lang);
    }
  }

  void _copyShareCode() {
    if (_vetShareLink == null) return;
    Clipboard.setData(ClipboardData(text: _vetShareLink!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedLanguage == 'km'
              ? 'បានចម្លងកូដដោយជោគជ័យ'
              : 'Share code copied to clipboard!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: primaryGreen,
      ),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isKhmer = _selectedLanguage == 'km';
        return AlertDialog(
          title: Text(isKhmer ? 'ចាកចេញ' : 'Log Out'),
          content: Text(
            isKhmer
                ? 'តើអ្នកពិតជាចង់ចាកចេញមែនទេ?'
                : 'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(isKhmer ? 'បោះបង់' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: logoutText),
              child: Text(
                isKhmer ? 'ចាកចេញ' : 'Log Out',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Clear stored authentication data
    await StorageService.clearAll();

    // Navigate to auth choice page with vet role
    if (mounted) {
      context.go('/auth-choice/vet/$_selectedLanguage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKhmer = _selectedLanguage == 'km';

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'VacTracker',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: primaryGreen),
            onPressed: () {
              _toggleLanguage(_selectedLanguage == 'en' ? 'km' : 'en');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Doctor Profile Card
              _buildDoctorProfileCard(isKhmer),
              const SizedBox(height: 20),

              // Language Settings Section
              _buildLanguageCard(isKhmer),
              const SizedBox(height: 16),

              // Notifications Settings Section
              _buildNotificationsCard(isKhmer),
              const SizedBox(height: 16),

              // Account Management Section
              _buildAccountManagementCard(isKhmer),
              const SizedBox(height: 16),

              // App Info Section
              _buildAppInfoCard(isKhmer),
              const SizedBox(height: 24),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: logoutText,
                    size: 20,
                  ),
                  label: Text(
                    isKhmer ? 'ចាកចេញ' : 'Log Out',
                    style: const TextStyle(
                      color: logoutText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoutBg,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _buildDoctorProfileCard(bool isKhmer) {
    if (_isLoadingProfile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              isKhmer ? 'មិនអាចផ្ទុកទិន្នន័យបាន' : 'Failed to load profile',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadProfileData,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(isKhmer ? 'ព្យាយាមម្តងទៀត' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final name =
        _profileData?['name'] ?? (isKhmer ? 'វេជ្ជបណ្ឌិត សុខា' : 'Dr. Sokha');
    final role = _profileData?['role'] ?? 'veterinarian';
    final profileImageUrl = _profileData?['profile_image_url'];

    // Get initials from name
    String initials = 'DS';
    if (name.isNotEmpty) {
      final nameParts = name.split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
        initials = nameParts[0][0].toUpperCase();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          if (profileImageUrl != null && profileImageUrl.isNotEmpty)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(profileImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isKhmer
                ? 'វេជ្ជបណ្ឌិតសត្វ • Veterinarian'
                : 'Veterinarian • វេជ្ជបណ្ឌិតសត្វ',
            style: const TextStyle(
              fontSize: 13,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badgeVerifiedBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isKhmer ? 'អ្នកជំនាញបានផ្ទៀងផ្ទាត់' : 'Verified Specialist',
              style: const TextStyle(
                color: badgeVerifiedText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(bool isKhmer) {
    return _buildSectionContainer(
      header: Row(
        children: [
          const Icon(Icons.translate, size: 20, color: textDark),
          const SizedBox(width: 8),
          Text(
            isKhmer ? 'ភាសា' : 'Language',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedLanguage == 'km' ? 'ភាសាខ្មែរ' : 'English',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _buildLangToggleBtn('KH', 'km'),
                  _buildLangToggleBtn('EN', 'en'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangToggleBtn(String label, String code) {
    final bool isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => _toggleLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(bool isKhmer) {
    return _buildSectionContainer(
      header: Row(
        children: [
          const Icon(
            Icons.notifications_none_outlined,
            size: 20,
            color: textDark,
          ),
          const SizedBox(width: 8),
          Text(
            isKhmer ? 'ការជូនដំណឹង' : 'Notifications',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _newSickReportsEnabled,
            // ignore: deprecated_member_use
            activeColor: primaryGreen,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            title: Text(
              isKhmer ? 'របាយការណ៍សត្វឈឺថ្មីៗ' : 'New Sick Reports',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            onChanged: (val) {
              setState(() => _newSickReportsEnabled = val);
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          SwitchListTile(
            value: _clientOverdueAlertsEnabled,
            // ignore: deprecated_member_use
            activeColor: primaryGreen,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            title: Text(
              isKhmer ? 'ការដាស់តឿនហួសកំណត់អតិថិជន' : 'Client Overdue Alerts',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            onChanged: (val) {
              setState(() => _clientOverdueAlertsEnabled = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementCard(bool isKhmer) {
    return _buildSectionContainer(
      header: Row(
        children: [
          const Icon(Icons.share_outlined, size: 20, color: textDark),
          const SizedBox(width: 8),
          Text(
            isKhmer ? 'ការគ្រប់គ្រងគណនី' : 'Account Management',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKhmer ? 'តំណភ្ជាប់ចែករំលែកគ្រូពេទ្យ' : 'Vet Share Link',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      _vetShareLink ?? 'FG-VET-SOKHA-2024',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _copyShareCode,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isKhmer
                  ? 'ចែករំលែកកូដនេះទៅកសិករ ដើម្បីឱ្យពួកគាត់អាចរាយការណ៍សត្វឈឺមកអ្នកបាន។'
                  : 'Share this code with farmers so they can report sick animals to you.',
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(bool isKhmer) {
    return _buildSectionContainer(
      header: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: textDark),
          const SizedBox(width: 8),
          Text(
            isKhmer ? 'ព័ត៌មានកម្មវិធី' : 'App Info',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              isKhmer ? 'លក្ខខណ្ឌសេវាកម្ម' : 'Terms of Service',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey[200]),
          const ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              'App Version',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            trailing: Text(
              'v2.4.0 (Guardian)',
              style: TextStyle(
                fontSize: 14,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required Widget header,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: cardHeaderBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: header,
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey[500],
      currentIndex: 3, // 'Profile' active selection
      onTap: (index) {
        if (index == 0) {
          // Navigate to vet dashboard
          context.push('/vet-dashboard?lang=${widget.currentLanguage}');
          return;
        } else if (index == 1) {
          // Navigate to reports
          context.push('/vet-reports?lang=${widget.currentLanguage}');
          return;
        } else if (index == 2) {
          // Navigate to farmers
          context.push('/my-farmers/${widget.currentLanguage}');
          return;
        }
      },
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
    );
  }
}
