// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';

class FarmerProfileModel {
  final int? userId;
  final String name;
  final String phone;
  final String role;
  final String village;
  final String province;
  final String languagePref;
  final String profileImageUrl;

  const FarmerProfileModel({
    this.userId,
    required this.name,
    required this.phone,
    required this.role,
    required this.village,
    required this.province,
    required this.languagePref,
    this.profileImageUrl = '',
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? 'farmer').toString();
    final languagePref = (json['language_pref'] ?? 'km').toString();
    final profileImageUrl =
        [
          json['profile_image_url'],
          json['avatar_url'],
          json['profile_image'],
          json['image_url'],
          json['photo_url'],
        ].firstWhere(
          (value) => value != null && value.toString().isNotEmpty,
          orElse: () => '',
        );

    return FarmerProfileModel(
      userId: json['user_id'] is int ? json['user_id'] : null,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: role,
      village: (json['village'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      languagePref: languagePref,
      profileImageUrl: profileImageUrl.toString(),
    );
  }
}

class FarmerProfilePage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'

  const FarmerProfilePage({super.key, required this.languageCode});

  @override
  State<FarmerProfilePage> createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  // Backend User Profile Data State
  FarmerProfileModel? _profile;
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;
  String? _profileError;

  // Notification Toggle States
  bool _vaccinationReminders = true;
  bool _sickReportUpdates = true;
  late String _currentLang;

  // Vet Connection State
  final TextEditingController _vetCodeController = TextEditingController();
  bool _isConnectingToVet = false;
  List<dynamic> _connectedVets = [];
  bool _isLoadingVets = false;

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color badgeGreenBg = Color(0xFFD1E7DD);
  static const Color alertRed = Color(0xFFC5221F);

  // Edit Profile Dialog palette
  static const Color dialogLightGreen = Color(0xFFEAF5EE);
  static const Color dialogInputBg = Color(0xFFF8FAF9);
  static const Color dialogInputBorder = Color(0xFFE0E7E2);
  static const Color dialogTextMain = Color(0xFF10251A);

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

      // Profile Image
      'lbl_change_photo': 'Change Photo',
      'lbl_take_photo': 'Take Photo',
      'lbl_choose_from_gallery': 'Choose from Gallery',
      'lbl_cancel': 'Cancel',
      'msg_select_image_source': 'Select image source',
      'msg_image_uploaded': 'Profile image updated successfully',
      'msg_image_upload_failed': 'Failed to update profile image',

      // Edit Profile Dialog
      'edit_title': 'Edit Profile',
      'edit_subtitle': 'Update your personal information',
      'sec_personal_info': 'Personal Information',
      'lbl_full_name': 'Full name *',
      'hint_full_name': 'Enter your full name',
      'lbl_phone': 'Phone number *',
      'hint_phone': 'Enter phone number',
      'sec_location': 'Location',
      'lbl_village': 'Village',
      'hint_village': 'Enter village',
      'lbl_province': 'Province',
      'hint_province': 'Enter province',
      'lbl_info_box': 'Please check your information before saving.',
      'btn_save_changes': 'Save Changes',
      'btn_saving': 'Saving...',
      'msg_required_fields': 'Name and phone are required.',
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

      // Profile Image
      'lbl_change_photo': 'ប្តូររូបថត',
      'lbl_take_photo': 'ថតរូប',
      'lbl_choose_from_gallery': 'ជ្រើសរើសពីឯកសារ',
      'lbl_cancel': 'បោះបង់',
      'msg_select_image_source': 'ជ្រើសរើសប្រភពរូបភាព',
      'msg_image_uploaded': 'បានធ្វើបច្ចុប្បន្នភាពរូបថតប្រវត្តិរូប',
      'msg_image_upload_failed':
          'បរាជ័យក្នុងការធ្វើបច្ចុប្បន្នភាពរូបថតប្រវត្តិរូប',

      // Edit Profile Dialog
      'edit_title': 'កែសម្រួលប្រវត្តិរូប',
      'edit_subtitle': 'ធ្វើបច្ចុប្បន្នភាពព័ត៌មានផ្ទាល់ខ្លួនរបស់អ្នក',
      'sec_personal_info': 'ព័ត៌មានផ្ទាល់ខ្លួន',
      'lbl_full_name': 'ឈ្មោះពេញ *',
      'hint_full_name': 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'lbl_phone': 'លេខទូរស័ព្ទ *',
      'hint_phone': 'បញ្ចូលលេខទូរស័ព្ទ',
      'sec_location': 'ទីតាំង',
      'lbl_village': 'ភូមិ',
      'hint_village': 'បញ្ចូលភូមិ',
      'lbl_province': 'ខេត្ត',
      'hint_province': 'បញ្ចូលខេត្ត',
      'lbl_info_box': 'សូមពិនិត្យព័ត៌មានរបស់អ្នកមុនពេលរក្សាទុក។',
      'btn_save_changes': 'រក្សាទុកការផ្លាស់ប្តូរ',
      'btn_saving': 'កំពុងរក្សាទុក...',
      'msg_required_fields': 'សូមបំពេញឈ្មោះ និងលេខទូរស័ព្ទ។',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    _loadStoredUserName();
    _fetchUserProfile();
    _loadConnectedVets();
  }

  @override
  void dispose() {
    _vetCodeController.dispose();
    super.dispose();
  }

  /// Fetch User Profile data from Backend API
  Future<void> _loadStoredUserName() async {
    final storedName = await StorageService.getName();
    final storedProfileImageUrl = await StorageService.getProfileImageUrl();
    if (!mounted) return;
    setState(() {
      if (storedName != null && storedName.isNotEmpty && _profile == null) {
        _profile = FarmerProfileModel(
          name: storedName,
          phone: '',
          role: '',
          village: '',
          province: '',
          languagePref: widget.languageCode,
          profileImageUrl: storedProfileImageUrl ?? '',
        );
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
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
            _profile = FarmerProfileModel.fromJson(data);
            _profileError = null;
            _isLoadingProfile = false;
          });
        }

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
        _profile = const FarmerProfileModel(
          name: 'Sovann Makara',
          phone: '+855 12 345 678',
          role: 'farmer',
          village: 'Phnom Penh',
          province: 'Phnom Penh',
          languagePref: 'km',
          profileImageUrl: '',
        );
        _profileError = null;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadConnectedVets() async {
    setState(() {
      _isLoadingVets = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/users/my-vets');
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
            _connectedVets = data is List ? data : [];
            _isLoadingVets = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingVets = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVets = false;
        });
      }
    }
  }

  Future<void> _connectToVet() async {
    final vetCode = _vetCodeController.text.trim();

    if (vetCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLang == 'km'
                ? 'សូមបញ្ចូលកូដវេជ្ជបណ្ឌិតសត្វ'
                : 'Please enter vet share code',
          ),
          backgroundColor: alertRed,
        ),
      );
      return;
    }

    setState(() {
      _isConnectingToVet = true;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to connect with a vet.'),
          ),
        );
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/users/connect-vet');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'vetShareCode': vetCode}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLang == 'km'
                  ? 'បានភ្ជាប់ជាមួយវេជ្ជបណ្ឌិតសត្វដោយជោគជ័យ'
                  : 'Successfully connected with veterinarian',
            ),
            backgroundColor: brandDarkGreen,
          ),
        );
        _vetCodeController.clear();
        await _loadConnectedVets();
      } else if (response.statusCode == 409) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLang == 'km'
                  ? 'មានការភ្ជាប់រួចហើយជាមួយវេជ្ជបណ្ឌិតសត្វនេះ'
                  : 'Connection already exists with this veterinarian',
            ),
            backgroundColor: alertRed,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLang == 'km'
                  ? 'មិនអាចភ្ជាប់ជាមួយវេជ្ជបណ្ឌិតសត្វបាន'
                  : 'Failed to connect with veterinarian',
            ),
            backgroundColor: alertRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLang == 'km'
                ? 'មិនអាចភ្ជាប់ជាមួយវេជ្ជបណ្ឌិតសត្វបាន'
                : 'Failed to connect with veterinarian',
          ),
          backgroundColor: alertRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingToVet = false;
        });
      }
    }
  }

  Future<void> _updateProfile({
    required String name,
    required String phone,
    required String village,
    required String province,
  }) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again to update your profile.'),
        ),
      );
      return;
    }

    if (_profile?.userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile is not available for update right now.'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingProfile = true;
      _profileError = null;
    });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users/${_profile!.userId}');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'village': village,
          'province': province,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedData = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _profile = FarmerProfileModel.fromJson(updatedData);
          _isSavingProfile = false;
        });
        await StorageService.saveUser(updatedData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _isSavingProfile = false;
          _profileError = 'Unable to update profile right now.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingProfile = false;
        _profileError = 'Unable to update profile right now.';
      });
    }
  }

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ??
        _localizedValues['en']![key]!;
  }

  Widget _buildHeaderAvatar({
    required String? avatarUrl,
    required String displayName,
    required double radius,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final hasAvatar = (avatarUrl ?? '').trim().isNotEmpty;
    final fallbackColor =
        backgroundColor ?? brandDarkGreen.withValues(alpha: 0.12);
    final fallbackText = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: fallbackColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              // ignore: unnecessary_underscores
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Text(
                    fallbackText,
                    style: TextStyle(
                      color: foregroundColor ?? brandDarkGreen,
                      fontSize: radius > 24 ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                fallbackText,
                style: TextStyle(
                  color: foregroundColor ?? brandDarkGreen,
                  fontSize: radius > 24 ? 18 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileName = _profile?.name.trim().isNotEmpty == true
        ? _profile!.name
        : 'User';

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            languageCode: widget.languageCode,
            color: brandDarkGreen,
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () =>
                context.push('/farmer-profile/${widget.languageCode}'),
            icon: _buildHeaderAvatar(
              avatarUrl: _profile?.profileImageUrl,
              displayName: profileName,
              radius: 18,
              backgroundColor: textGreyLight,
              foregroundColor: brandDarkGreen,
            ),
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

              if (_profileError != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: alertRed.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _profileError!,
                    style: const TextStyle(color: alertRed, fontSize: 13),
                  ),
                ),
              ],

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

              // Vet Connection Section Card
              _buildSectionWrapper(
                title: _currentLang == 'km'
                    ? 'វេជ្ជបណ្ឌិតសត្វ'
                    : 'VETERINARIAN',
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show connection status (all connections are auto-accepted)
                      if (_connectedVets.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: badgeGreenBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: brandDarkGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: brandDarkGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _currentLang == 'km'
                                      ? 'បានភ្ជាប់ជាមួយវេជ្ជបណ្ឌិតសត្វរួចហើយ'
                                      : 'Connected with veterinarian',
                                  style: TextStyle(
                                    color: brandDarkGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _vetCodeController,
                                    decoration: InputDecoration(
                                      hintText: _currentLang == 'km'
                                          ? 'បញ្ចូលកូដវេជ្ជបណ្ឌិតសត្វ'
                                          : 'Enter vet share code',
                                      hintStyle: TextStyle(
                                        color: textGrey.withValues(alpha: 0.6),
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: textGreyLight,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: textGreyLight,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: brandDarkGreen,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isConnectingToVet
                                      ? null
                                      : _connectToVet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandDarkGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isConnectingToVet
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(
                                          Icons.add_rounded,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentLang == 'km'
                                  ? 'សួរថ្ងៃទីចែករំលែកកូដពីវេជ្ជបណ្ឌិតសត្វរបស់អ្នក'
                                  : 'Ask your vet for their share code to connect',
                              style: TextStyle(
                                color: textGrey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Connected Vets List
                      if (_isLoadingVets)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: brandDarkGreen,
                            ),
                          ),
                        )
                      else if (_connectedVets.isNotEmpty)
                        ...(_connectedVets
                            .map(
                              (vet) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: textGreyLight),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.medical_services_rounded,
                                        color: brandDarkGreen,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vet['name'] ?? 'Unknown Vet',
                                              style: const TextStyle(
                                                color: textDarkBlue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (vet['phone'] != null)
                                              Text(
                                                vet['phone'],
                                                style: TextStyle(
                                                  color: textGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: brandDarkGreen,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList())
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _currentLang == 'km'
                                  ? 'មិនមានវេជ្ជបណ្ឌិតសត្វដែលភ្ជាប់'
                                  : 'No connected veterinarians',
                              style: TextStyle(
                                color: textGrey.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // App Info Section Card
              _buildSectionWrapper(
                title: _getText('sec_app_info'),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'VacTracker',
                        applicationVersion: '1.0.0',
                      ),
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
    final profile = _profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: _isLoadingProfile
          ? const SizedBox(
              height: 92,
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
                      child: _buildHeaderAvatar(
                        avatarUrl: profile?.profileImageUrl,
                        displayName: profile?.name.trim().isNotEmpty == true
                            ? profile!.name
                            : 'User',
                        radius: 34,
                        backgroundColor: const Color(
                          0xFFA2F39B,
                        ).withValues(alpha: 0.4),
                        foregroundColor: brandDarkGreen,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _isLoadingProfile || _isSavingProfile
                            ? null
                            : _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: brandDarkGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _isLoadingProfile || _isSavingProfile
                        ? null
                        : _showEditProfileDialog,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile?.name.isNotEmpty == true
                                    ? profile!.name
                                    : 'Farmer Profile',
                                style: const TextStyle(
                                  color: brandDarkGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.edit_rounded, color: textGrey, size: 20),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.phone.isNotEmpty == true
                              ? profile!.phone
                              : 'No phone number yet',
                          style: const TextStyle(color: textGrey, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        if ((profile?.village ?? '').isNotEmpty ||
                            (profile?.province ?? '').isNotEmpty)
                          Text(
                            [profile?.village, profile?.province]
                                .where((value) => (value ?? '').isNotEmpty)
                                .join(', '),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 13,
                            ),
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
                            profile?.role.isNotEmpty == true
                                ? profile!.role.toUpperCase()
                                : 'FARMER',
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
                ),
              ],
            ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _profile?.name ?? '');
    final phoneController = TextEditingController(text: _profile?.phone ?? '');
    final villageController = TextEditingController(
      text: _profile?.village ?? '',
    );
    final provinceController = TextEditingController(
      text: _profile?.province ?? '',
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: !_isSavingProfile,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: LayoutBuilder(
            builder: (context, viewport) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: viewport.maxHeight - 48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(dialogContext),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogSectionHeader(
                              icon: Icons.person_outline_rounded,
                              title: _getText('sec_personal_info'),
                            ),
                            const SizedBox(height: 12),
                            _buildDialogField(
                              controller: nameController,
                              icon: Icons.person_outline_rounded,
                              label: _getText('lbl_full_name'),
                              hint: _getText('hint_full_name'),
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogField(
                              controller: phoneController,
                              icon: Icons.phone_outlined,
                              label: _getText('lbl_phone'),
                              hint: _getText('hint_phone'),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            _buildDialogSectionHeader(
                              icon: Icons.location_on_outlined,
                              title: _getText('sec_location'),
                            ),
                            const SizedBox(height: 12),
                            _buildDialogField(
                              controller: villageController,
                              icon: Icons.home_outlined,
                              label: _getText('lbl_village'),
                              hint: _getText('hint_village'),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogField(
                              controller: provinceController,
                              icon: Icons.map_outlined,
                              label: _getText('lbl_province'),
                              hint: _getText('hint_province'),
                            ),
                            const SizedBox(height: 18),
                            _buildDialogInfoBox(),
                          ],
                        ),
                      ),
                    ),
                    _buildDialogActions(
                      dialogContext,
                      nameController,
                      phoneController,
                      villageController,
                      provinceController,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(BuildContext dialogContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: const BoxDecoration(
        color: brandDarkGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getText('edit_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getText('edit_subtitle'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSavingProfile
                ? null
                : () => Navigator.of(dialogContext).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: _getText('lbl_cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: dialogLightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: brandDarkGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: dialogTextMain,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: dialogTextMain,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: dialogTextMain, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: textGrey, fontSize: 14),
            prefixIcon: Icon(icon, color: brandDarkGreen, size: 20),
            filled: true,
            fillColor: dialogInputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: dialogInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: brandDarkGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dialogLightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: brandDarkGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getText('lbl_info_box'),
              style: const TextStyle(
                color: brandDarkGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(
    BuildContext dialogContext,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController villageController,
    TextEditingController provinceController,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: dialogInputBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isSavingProfile
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandDarkGreen,
                  side: const BorderSide(color: dialogInputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getText('lbl_cancel'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSavingProfile
                    ? null
                    : () => _saveEditProfile(
                        dialogContext,
                        nameController,
                        phoneController,
                        villageController,
                        provinceController,
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: brandDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSavingProfile
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _isSavingProfile
                      ? _getText('btn_saving')
                      : _getText('btn_save_changes'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEditProfile(
    BuildContext dialogContext,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController villageController,
    TextEditingController provinceController,
  ) async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final village = villageController.text.trim();
    final province = provinceController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getText('msg_required_fields'))),
      );
      return;
    }

    Navigator.of(dialogContext).pop();
    await _updateProfile(
      name: name,
      phone: phone,
      village: village,
      province: province,
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_getText('msg_select_image_source')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: brandDarkGreen,
                ),
                title: Text(_getText('lbl_take_photo')),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: brandDarkGreen,
                ),
                title: Text(_getText('lbl_choose_from_gallery')),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_getText('lbl_cancel')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image == null) return;


      await _uploadProfileImage(image);
    } catch (e) {
      print('❌ Pick image error: $e');
    }
  }

  Future<void> _uploadProfileImage(XFile image) async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      print('❌ No JWT token');
      return;
    }

    try {
      setState(() {
        _isSavingProfile = true;
      });

      final url = '${ApiConfig.baseUrl}/users/upload-profile-image';

      print('📤 Upload URL: $url');
      print('📤 Image path: ${image.path}');
      print('📤 Token exists: ${token.isNotEmpty}');

      // Read image as bytes - works on Web, Android, iOS
      final bytes = await image.readAsBytes();

      print('📦 Image size: ${bytes.length} bytes');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      // Upload bytes instead of using fromPath()
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: image.name),
      );

      print('📤 Sending image...');

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        print('✅ Upload successful');
        print('☁️ Cloudinary URL: ${data['profile_image_url']}');

        if (!mounted) return;

        setState(() {
          _profile = FarmerProfileModel.fromJson(data);
          _isSavingProfile = false;
        });

        await StorageService.saveUser(data);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('msg_image_uploaded')),
            backgroundColor: brandDarkGreen,
          ),
        );
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        print('❌ Response: ${response.body}');

        if (!mounted) return;

        setState(() {
          _isSavingProfile = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Upload exception: $e');
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        _isSavingProfile = false;
      });
    }
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
    return FarmerBottomNavigation(currentIndex: 4, languageCode: _currentLang);
  }
}
