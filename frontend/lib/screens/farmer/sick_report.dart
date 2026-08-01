import 'package:flutter/material.dart';

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
  String _selectedFlock = 'Flock A - Batch #204 (Active)';
  final List<String> _selectedSymptoms = [];
  final TextEditingController _detailsController = TextEditingController();
  final List<String> _uploadedPhotos = [
    'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=500', // Mock photo
  ];

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
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
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
            icon: const Icon(Icons.language, color: primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  child: DropdownButton<String>(
                    value: _selectedFlock,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: textDark,
                    ),
                    items:
                        [
                          'Flock A - Batch #204 (Active)',
                          'Flock B - Batch #102 (Active)',
                          'Flock C - Batch #088 (Quarantine)',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
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
                        setState(() => _selectedFlock = newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Visual Evidence Section
              Text(
                _getText('visual_evidence'),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Add Photo Button
                  GestureDetector(
                    onTap: () {
                      // Handle Image Picker
                    },
                    child: Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: inputBorder,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo_outlined,
                            color: primaryGreen,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getText('add_photo'),
                            style: const TextStyle(
                              color: primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Uploaded Image Previews
                  ..._uploadedPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imageUrl = entry.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 130,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _uploadedPhotos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getText('photo_hint'),
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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
                  hintStyle: const TextStyle(color: textMuted, fontSize: 14),
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
                  onPressed: () {
                    // Submit action logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey[500],
      currentIndex: 2,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.vaccines_outlined),
          label: 'Vaccines',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Records',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
