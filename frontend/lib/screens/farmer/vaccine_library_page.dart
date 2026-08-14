import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class VaccineLibraryItem {
  final String id;
  final String nameKm;
  final String nameEn;
  final String tag; // Essential, Standard, Critical
  final String strain;
  final String optimalAgeKm;
  final String optimalAgeEn;
  final String methodKm;
  final String methodEn;
  final String category; // broilers, layers, emergency, all
  final String instructionsKm;
  final String instructionsEn;

  VaccineLibraryItem({
    required this.id,
    required this.nameKm,
    required this.nameEn,
    required this.tag,
    required this.strain,
    required this.optimalAgeKm,
    required this.optimalAgeEn,
    required this.methodKm,
    required this.methodEn,
    required this.category,
    required this.instructionsKm,
    required this.instructionsEn,
  });

  factory VaccineLibraryItem.fromJson(Map<String, dynamic> json) {
    return VaccineLibraryItem(
      id: json['id']?.toString() ?? '',
      nameKm: json['nameKm'] ?? '',
      nameEn: json['nameEn'] ?? '',
      tag: json['tag'] ?? 'Standard',
      strain: json['strain'] ?? '',
      optimalAgeKm: json['optimalAgeKm'] ?? '',
      optimalAgeEn: json['optimalAgeEn'] ?? '',
      methodKm: json['methodKm'] ?? '',
      methodEn: json['methodEn'] ?? '',
      category: json['category'] ?? 'all',
      instructionsKm: json['instructionsKm'] ?? '',
      instructionsEn: json['instructionsEn'] ?? '',
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
  int _currentIndex = 3; // Library tab highlighted in bottom nav
  late String _currentLang;

  // Filter & Search State
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Data State
  List<VaccineLibraryItem> _allVaccines = [];
  List<VaccineLibraryItem> _filteredVaccines = [];
  bool _isLoading = true;

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
      'search_hint': 'ស្វែងរកវ៉ាក់សាំង ជំងឺ...',
      'btn_filter': 'តម្រង',
      'cat_all': 'ទាំងអស់',
      'cat_broilers': 'មាន់សាច់',
      'cat_layers': 'មាន់យកពង',
      'cat_emergency': 'បន្ទាន់',
      'lbl_optimal_age': 'អាយុស័ក្តិសម',
      'lbl_method': 'វិធីសាស្ត្រ',
      'lbl_instructions': 'ការណែនាំអំពីការប្រើប្រាស់',
      'guide_title': 'សៀវភៅណែនាំការចាក់វ៉ាក់សាំង ២០២៦',
      'guide_subtitle': 'ទាញយកសៀវភៅណែនាំតំបន់ពេញលេញសម្រាប់កសិដ្ឋានកម្ពុជា។',
    },
    'en': {
      'page_title': 'Vaccine Library',
      'search_hint': 'Search vaccines, diseases...',
      'btn_filter': 'Filter',
      'cat_all': 'All',
      'cat_broilers': 'Broilers',
      'cat_layers': 'Layers',
      'cat_emergency': 'Emergency',
      'lbl_optimal_age': 'Optimal Age',
      'lbl_method': 'Method',
      'lbl_instructions': 'Usage Instructions',
      'guide_title': 'Vaccination Guide 2026',
      'guide_subtitle':
          'Download the complete regional handbook for Cambodian farms.',
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
    try {
      final response = await http.get(
        Uri.parse(
          'https://your-api-domain.com/api/v1/vaccine-library?lang=$_currentLang',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetched = data
            .map((item) => VaccineLibraryItem.fromJson(item))
            .toList();

        setState(() {
          _allVaccines = fetched;
          _filteredVaccines = fetched;
          _isLoading = false;
        });
      } else {
        _useFallbackData();
      }
    } catch (e) {
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    final mockData = [
      VaccineLibraryItem(
        id: 'nd',
        nameKm: 'ជំងឺញូកាស (ND)',
        nameEn: 'Newcastle Disease (ND)',
        tag: 'Essential',
        strain: 'LIVE VIRUS / LASOTA STRAIN',
        optimalAgeKm: 'ថ្ងៃទី ៧ និង ថ្ងៃទី ២១',
        optimalAgeEn: 'Day 7 & Day 21',
        methodKm: 'បន្តក់ភ្នែក / ទឹក',
        methodEn: 'Eye Drop / Water',
        category: 'broilers',
        instructionsKm:
            'លាយវ៉ាក់សាំងជាមួយទឹកស្អាតគ្មានក្លរ ឬបន្តក់ភ្នែកសត្វម្តងមួយក្បាល។',
        instructionsEn:
            'Mix vaccine with clean chlorine-free water or drop directly into eye.',
      ),
      VaccineLibraryItem(
        id: 'ib',
        nameKm: 'ជំងឺរលាកទងសួត (IB)',
        nameEn: 'Infectious Bronchitis (IB)',
        tag: 'Standard',
        strain: 'H120 STRAIN',
        optimalAgeKm: 'ថ្ងៃទី ១ (រោងភ្ញាស់)',
        optimalAgeEn: 'Day 1 (Hatchery)',
        methodKm: 'បាញ់ផ្សែង/ដំណក់ធំ',
        methodEn: 'Coarse Spray',
        category: 'layers',
        instructionsKm:
            'ប្រើប្រាស់ម៉ាស៊ីនបាញ់ថ្នាំដំណក់ធំនៅថ្ងៃដំបូងដែលកូនមាន់ញាស់។',
        instructionsEn: 'Use coarse spray equipment on chicks on hatching day.',
      ),
      VaccineLibraryItem(
        id: 'fowl_pox',
        nameKm: 'វ៉ាក់សាំងអុតមាន់',
        nameEn: 'Fowl Pox Vaccine',
        tag: 'Critical',
        strain: 'WING WEB APPLICATION',
        optimalAgeKm: 'សប្តាហ៍ទី ៨ - ១០',
        optimalAgeEn: 'Week 8 - 10',
        methodKm: 'ចាក់ច្លុះស្លាប',
        methodEn: 'Wing Web Stab',
        category: 'emergency',
        instructionsKm:
            'ប្រើម្ជុលពីរខ្នែងចាក់ទម្លុះស្បែកស្តើងនៅចន្លោះស្លាបមាន់។',
        instructionsEn:
            'Use double-needle applicator to pierce skin web of the wing.',
      ),
    ];

    if (mounted) {
      setState(() {
        _allVaccines = mockData;
        _filteredVaccines = mockData;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredVaccines = _allVaccines.where((item) {
        final matchesCat =
            _selectedCategory == 'all' || item.category == _selectedCategory;
        final name = _currentLang == 'km' ? item.nameKm : item.nameEn;
        final matchesSearch =
            name.toLowerCase().contains(query) ||
            item.strain.toLowerCase().contains(query);
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
          IconButton(
            icon: const Icon(Icons.language_rounded, color: brandDarkGreen),
            onPressed: () {
              setState(() {
                _currentLang = _currentLang == 'km' ? 'en' : 'km';
              });
            },
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
              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilter(),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _getText('search_hint'),
                        hintStyle: const TextStyle(
                          color: textGrey,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: textGrey,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _selectedCategory = 'all';
                      _applyFilter();
                    }),
                    icon: const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: brandDarkGreen,
                    ),
                    label: Text(
                      _getText('btn_filter'),
                      style: const TextStyle(
                        color: brandDarkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryPill('all', _getText('cat_all')),
                    _buildCategoryPill('broilers', _getText('cat_broilers')),
                    _buildCategoryPill('layers', _getText('cat_layers')),
                    _buildCategoryPill('emergency', _getText('cat_emergency')),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic List of Vaccines + Banner
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: brandDarkGreen),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVaccines.length + 1, // Include Banner
                      itemBuilder: (context, index) {
                        // Insert Banner at index 2 (matching screenshot position)
                        if (index == 2) {
                          return Column(
                            children: [
                              _buildHandbookBanner(),
                              const SizedBox(height: 16),
                              if (index < _filteredVaccines.length)
                                _buildVaccineCard(_filteredVaccines[index]),
                            ],
                          );
                        }

                        final itemIndex = index > 2 ? index - 1 : index;
                        if (itemIndex < _filteredVaccines.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildVaccineCard(
                              _filteredVaccines[itemIndex],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
    final age = _currentLang == 'km' ? item.optimalAgeKm : item.optimalAgeEn;
    final method = _currentLang == 'km' ? item.methodKm : item.methodEn;
    final instructions = _currentLang == 'km'
        ? item.instructionsKm
        : item.instructionsEn;

    // Badge styling based on Tag
    Color tagBgColor;
    Color tagTextColor;
    IconData leadingIcon = Icons.vaccines;

    switch (item.tag.toLowerCase()) {
      case 'essential':
        tagBgColor = const Color(0xFFD1FAE5);
        tagTextColor = const Color(0xFF065F46);
        break;
      case 'critical':
        tagBgColor = const Color(0xFFFEE2E2);
        tagTextColor = const Color(0xFF991B1B);
        leadingIcon = Icons.warning_amber_rounded;
        break;
      default: // Standard
        tagBgColor = const Color(0xFFE2E8F0);
        tagTextColor = const Color(0xFF334155);
        leadingIcon = Icons.medical_services_outlined;
    }

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
          // Top Row Icon, Name & Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.tag.toLowerCase() == 'critical'
                      ? const Color(0xFFFEE2E2)
                      : item.tag.toLowerCase() == 'standard'
                      ? const Color(0xFFE2E8F0)
                      : brandDarkGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  leadingIcon,
                  color: item.tag.toLowerCase() == 'critical'
                      ? const Color(0xFF991B1B)
                      : item.tag.toLowerCase() == 'standard'
                      ? textDarkBlue
                      : Colors.white,
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
                      item.strain,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.tag,
                  style: TextStyle(
                    color: tagTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two Info Boxes Grid (Optimal Age & Method)
          Row(
            children: [
              // Optimal Age
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardSubBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getText('lbl_optimal_age'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        age,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Method
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardSubBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getText('lbl_method'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        method,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expandable Usage Instructions
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(
                _getText('lbl_instructions'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Text(
                  instructions,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vaccination Guide Banner Widget
  Widget _buildHandbookBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=800',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getText('guide_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getText('guide_subtitle'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          if (index == 1) {
            context.go('/log-vaccination-step1/$_currentLang');
          } else if (index == 2) {
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.vaccines_outlined, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: brandDarkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 20),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book, size: 26),
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
