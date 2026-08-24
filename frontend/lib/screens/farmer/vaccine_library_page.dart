import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/services/vaccine_library_service.dart';
import 'package:frontend/widgets/notification_header_button.dart';
import 'package:frontend/widgets/farmer_bottom_navigation.dart';

class VaccineLibraryItem {
  final String id;
  final String nameEn;
  final String nameKm;
  final String diseaseEn;
  final String diseaseKm;
  final String descriptionEn;
  final String descriptionKm;
  final String category;

  VaccineLibraryItem({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.diseaseEn,
    required this.diseaseKm,
    required this.descriptionEn,
    required this.descriptionKm,
    required this.category,
  });

  factory VaccineLibraryItem.fromJson(Map<String, dynamic> json) {
    return VaccineLibraryItem(
      id: json['library_id']?.toString() ?? '',
      nameEn: json['name_en'] ?? '',
      nameKm: json['name_km'] ?? '',
      diseaseEn: json['disease_en'] ?? '',
      diseaseKm: json['disease_km'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionKm: json['description_km'] ?? '',
      category: json['category'] ?? 'general',
    );
  }
}

class VaccineLibraryPage extends StatefulWidget {
  final String languageCode; // 'km' or 'en'

  const VaccineLibraryPage({super.key, this.languageCode = 'km'});

  @override
  State<VaccineLibraryPage> createState() => _VaccineLibraryPageState();
}

class _VaccineLibraryPageState extends State<VaccineLibraryPage> {
  late String _currentLang;

  // Filter & Search State
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Data State
  List<VaccineLibraryItem> _allVaccines = [];
  List<VaccineLibraryItem> _filteredVaccines = [];
  bool _isLoading = true;

  final VaccineLibraryService _libraryService = VaccineLibraryService();

  // Design System Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color cardSubBg = Color(0xFFF1F5F9);

  // Dictionary for Khmer & English Translations
  final Map<String, Map<String, String>> _localizedValues = const {
    'km': {
      'page_title': 'បណ្ណាល័យវ៉ាក់សាំង',
      'search_hint': 'ស្វែងរកវ៉ាក់សាំង ឬជំងឺ...',
      'cat_all': 'ទាំងអស់',
      'cat_core': 'ស្នូល',
      'cat_reportable': 'ត្រូវរាយការណ៍',
      'lbl_protects_against': 'ការពារពីជំងឺ៖',
      'lbl_why_important': 'ហេតុអ្វីសំខាន់៖',
      'btn_learn_more': 'ស្វែងយល់បន្ថែម',
      'err_load': 'មិនអាចទាញយកទិន្នន័យបានទេ',
      'lbl_retry': 'ព្យាយាមម្តងទៀត',
      'empty_state': 'រកមិនឃើញវ៉ាក់សាំងទេ',
    },
    'en': {
      'page_title': 'Vaccine Library',
      'search_hint': 'Search vaccines or diseases...',
      'cat_all': 'All',
      'cat_core': 'Core',
      'cat_reportable': 'Reportable',
      'lbl_protects_against': 'Protects against:',
      'lbl_why_important': 'Why important:',
      'btn_learn_more': 'Learn More',
      'err_load': 'Failed to load data',
      'lbl_retry': 'Retry',
      'empty_state': 'No vaccines found',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    _fetchVaccineLibraryData();
  }

  /// 1. Fetch Vaccine Library Details from Backend API
  Future<void> _fetchVaccineLibraryData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _libraryService.fetchLibrary(lang: _currentLang);

      final fetched = data
          .map(
            (item) => VaccineLibraryItem.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      if (mounted) {
        setState(() {
          _allVaccines = fetched;
          _filteredVaccines = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredVaccines = _allVaccines.where((item) {
        final matchesCat =
            _selectedCategory == 'all' || item.category == _selectedCategory;
        final nameEn = item.nameEn.toLowerCase();
        final nameKm = item.nameKm.toLowerCase();
        final diseaseEn = item.diseaseEn.toLowerCase();
        final diseaseKm = item.diseaseKm.toLowerCase();
        final matchesSearch =
            nameEn.contains(query) ||
            nameKm.contains(query) ||
            diseaseEn.contains(query) ||
            diseaseKm.contains(query);
        return matchesCat && matchesSearch;
      }).toList();
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationHeaderButton(
            languageCode: _currentLang,
            color: brandDarkGreen,
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
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilter(),
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

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryPill('all', _getText('cat_all')),
                    _buildCategoryPill('core', _getText('cat_core')),
                    _buildCategoryPill(
                      'reportable',
                      _getText('cat_reportable'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic List of Vaccines
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: brandDarkGreen),
                    )
                  : _filteredVaccines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          _getText('empty_state'),
                          style: const TextStyle(color: textGrey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVaccines.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildVaccineCard(_filteredVaccines[index]),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Category Selector Pill Component
  Widget _buildCategoryPill(String id, String label) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
          _applyFilter();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? brandDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? brandDarkGreen : textGreyLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textDarkBlue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Individual Vaccine Card Widget
  Widget _buildVaccineCard(VaccineLibraryItem item) {
    final name = _currentLang == 'km' ? item.nameKm : item.nameEn;
    final disease = _currentLang == 'km' ? item.diseaseKm : item.diseaseEn;
    final description = _currentLang == 'km'
        ? item.descriptionKm
        : item.descriptionEn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row Icon & Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: brandDarkGreen,
                  borderRadius: BorderRadius.circular(12),
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
                      name,
                      style: const TextStyle(
                        color: brandDarkGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentLang == 'km' ? item.nameEn : item.nameKm,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Protects Against
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardSubBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getText('lbl_protects_against'),
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  disease,
                  style: const TextStyle(
                    color: textDarkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Short Explanation
          Text(
            description,
            style: const TextStyle(color: textGrey, fontSize: 13, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // Learn More Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push(
                  '/vaccine-library-detail/${item.id}/$_currentLang',
                );
              },
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(
                _getText('btn_learn_more'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: brandDarkGreen,
                side: const BorderSide(color: brandDarkGreen, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return FarmerBottomNavigation(
      currentIndex: 3,
      languageCode: _currentLang,
    );
  }
}
