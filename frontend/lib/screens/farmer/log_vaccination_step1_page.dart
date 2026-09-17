import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';
// ignore: library_prefixes
import 'package:frontend/models/flock.dart' as Fm;

class FlockBatchModel {
  final String id;
  final String name; // e.g., "ក្រុមមាន់ A"
  final int count; // e.g., 500
  final int ageWeeks; // e.g., 3
  final String status; // e.g., "សុខភាពល្អ"

  FlockBatchModel({
    required this.id,
    required this.name,
    required this.count,
    required this.ageWeeks,
    required this.status,
  });

  factory FlockBatchModel.fromJson(Map<String, dynamic> json) {
    return FlockBatchModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      ageWeeks: json['ageWeeks'] ?? 0,
      status: json['status'] ?? 'សុខភាពល្អ',
    );
  }
}

class LogVaccinationStep1Page extends StatefulWidget {
  final String languageCode; // Defaults to 'km' or 'en'

  const LogVaccinationStep1Page({super.key, this.languageCode = 'km'});

  @override
  State<LogVaccinationStep1Page> createState() =>
      _LogVaccinationStep1PageState();
}

class _LogVaccinationStep1PageState extends State<LogVaccinationStep1Page> {
  late String _currentLang;
  String _profileName = '';
  String _profileImageUrl = '';

  // Backend Data State
  List<FlockBatchModel> _allFlocks = [];
  List<FlockBatchModel> _filteredFlocks = [];
  String? _selectedFlockId;
  bool _isLoading = true;

  final FlockService _flockService = FlockService();

  final TextEditingController _searchController = TextEditingController();

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color greenAccent = Color(0xFF108038);

  // Localization Dictionary
  final Map<String, Map<String, String>> _localizedValues = const {
    'km': {
      'app_bar_title': 'VacTracker',
      'step_label': 'ជំហានទី ១ នៃ ២',
      'page_title': 'ជ្រើសរើសហ្វូងសត្វ',
      'subtitle':
          'ជ្រើសរើសក្រុមបក្សីជាក់លាក់សម្រាប់កាលវិភាគចាក់វ៉ាក់សាំងថ្ងៃនេះ។',
      'search_hint': 'ស្វែងរកលេខសម្គាល់ក្រុម ឬផ្ទះ...',
      'birds_unit': 'ក្បាល',
      'age_unit': 'សប្តាហ៍',
      'btn_next': 'ជំហានបន្ទាប់',
      'err_select_flock': 'សូមជ្រើសរើសហ្វូងសត្វមួយជាមុនសិន',
      'err_fetch_failed': 'មិនអាចទាញយកទិន្នន័យបានទេ',
      'lbl_retry': 'ព្យាយាមម្តងទៀត',
    },
    'en': {
      'app_bar_title': 'VacTracker',
      'step_label': 'STEP 1 OF 2',
      'page_title': 'Select Flock',
      'subtitle':
          'Select a specific bird group for today\'s vaccination schedule.',
      'search_hint': 'Search group ID or house...',
      'birds_unit': 'Birds',
      'age_unit': 'Weeks',
      'btn_next': 'Next Step',
      'err_select_flock': 'Please select a flock first',
      'err_fetch_failed': 'Failed to load flocks',
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
    _fetchFlocksFromBackend();
  }

  /// Fetches Flock/Batch List from Backend API
  Future<void> _fetchFlocksFromBackend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use FlockService to fetch flocks (uses ApiConfig + auth)
      final List<Fm.Flock> flocks = await _flockService.fetchFlocks();

      final fetchedFlocks = flocks.map((f) {
        return FlockBatchModel(
          id: f.flockId.toString(),
          name: f.batchName,
          count: f.birdCount,
          ageWeeks: (f.ageInDays ~/ 7),
          status: 'សុខភាពល្អ',
        );
      }).toList();

      setState(() {
        _allFlocks = fetchedFlocks;
        _filteredFlocks = fetchedFlocks;
        if (_allFlocks.isNotEmpty) {
          _selectedFlockId = _allFlocks.first.id; // Auto select first item
        }
        _isLoading = false;
      });
    } catch (e) {
      _useFallbackData();
    }
  }

  /// Fallback matching Khmer design mockup if network request is offline
  void _useFallbackData() {
    final mockFlocks = [
      FlockBatchModel(
        id: 'flock_a',
        name: 'ក្រុមមាន់ A',
        count: 500,
        ageWeeks: 3,
        status: 'សុខភាពល្អ',
      ),
      FlockBatchModel(
        id: 'flock_b',
        name: 'ក្រុមមាន់ B',
        count: 1200,
        ageWeeks: 5,
        status: 'សុខភាពល្អ',
      ),
      FlockBatchModel(
        id: 'flock_c',
        name: 'ក្រុមមាន់ C',
        count: 320,
        ageWeeks: 2,
        status: 'សុខភាពល្អ',
      ),
    ];

    if (mounted) {
      setState(() {
        _allFlocks = mockFlocks;
        _filteredFlocks = mockFlocks;
        _selectedFlockId = 'flock_a';
        _isLoading = false;
      });
    }
  }

  void _filterFlocks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFlocks = _allFlocks;
      } else {
        _filteredFlocks = _allFlocks
            .where(
              (flock) => flock.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Step Label & Title
              Text(
                _getText('step_label'),
                style: const TextStyle(
                  color: greenAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getText('page_title'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getText('subtitle'),
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // Step Progress Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: brandDarkGreen,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: textGreyLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _filterFlocks,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _getText('search_hint'),
                  hintStyle: const TextStyle(color: textGrey, fontSize: 13),
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

              const SizedBox(height: 16),

              // List of Flocks / Loading State
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: brandDarkGreen),
                      )
                    : _filteredFlocks.isEmpty
                    ? Center(
                        child: Text(
                          _getText('err_fetch_failed'),
                          style: const TextStyle(color: textGrey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredFlocks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final flock = _filteredFlocks[index];
                          final isSelected = _selectedFlockId == flock.id;
                          return _buildFlockCard(flock, isSelected);
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // Next Step Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedFlockId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_getText('err_select_flock'))),
                      );
                      return;
                    }
                    final selectedFlock = _allFlocks.firstWhere(
                      (f) => f.id == _selectedFlockId,
                    );

                    // Navigate to Step 2 passing parameters (flockId and batchTitle as query params)
                    final url =
                        '/log-vaccination-step2/$_currentLang?flockId=${selectedFlock.id}&batchTitle=${selectedFlock.name}';
                    debugPrint('Navigating to: $url');
                    final router = GoRouter.of(context);
                    final result = await router.push<bool>(url);
                    if (!mounted) return;
                    if (result == true) {
                      router.pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDarkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getText('btn_next'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Flock Card Item UI Component
  Widget _buildFlockCard(FlockBatchModel flock, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFlockId = flock.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandDarkGreen : textGreyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Green Highlight Indicator
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: isSelected ? brandDarkGreen : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: brandDarkGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              // Title & Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        flock.name,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '#',
                            style: TextStyle(
                              color: textGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'មាន់ ${flock.count} ${_getText('birds_unit')}   អាយុ ${flock.ageWeeks} ${_getText('age_unit')}',
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: greenAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            flock.status,
                            style: const TextStyle(
                              color: brandDarkGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Chevron Right Arrow
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: textGrey,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return FarmerBottomNavigation(currentIndex: 1, languageCode: _currentLang);
  }
}
