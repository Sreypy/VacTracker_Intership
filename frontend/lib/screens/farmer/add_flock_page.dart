import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/storage_service.dart';

class AddFlockPage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'
  final Flock? editingFlock;
  final String? profileImageUrl;

  const AddFlockPage({
    super.key,
    required this.languageCode,
    this.editingFlock,
    this.profileImageUrl,
  });

  @override
  State<AddFlockPage> createState() => _AddFlockPageState();
}

class _AddFlockPageState extends State<AddFlockPage> {
  int _currentIndex = 2;
  String _selectedBreed = 'Broiler';
  bool _isSaving = false;

  // State text controllers
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _birdCountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Styling Theme Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);

  static const Color alertBgGreen = Color(0xFFF2F8F4);
  static const Color alertBorderGreen = Color(0xFFD1E7DD);

  // Localization Dictionary
  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'app_bar_title': 'Add Flock',
      'banner_title': 'New Batch Registration',
      'banner_desc': 'Log your flock details for precise vaccination tracking.',
      'lbl_batch_name': 'Batch Name',
      'hint_batch_name': 'e.g., North Barn Chickens 01',
      'lbl_bird_count': 'Bird Count',
      'lbl_date': 'Date Acquired',
      'lbl_breed': 'Breed / Type',
      'breed_broiler': 'Broiler',
      'breed_layer': 'Layer',
      'breed_local': 'Local Breed',
      'guardian_title': 'Guardian Check',
      'guardian_desc':
          'Registering your flock allows our veterinary system to automatically generate a recommended vaccination schedule based on Cambodian poultry health guidelines.',
      'btn_save': 'Save Flock',
      'btn_save_edit': 'Update Flock',
      'btn_saving': 'Saving...',
      'btn_cancel': 'Cancel',
      'app_bar_title_edit': 'Edit Flock',
      'banner_title_edit': 'Update Flock Details',
      'err_empty_name': 'Please enter a batch name',
      'err_invalid_count': 'Please enter a valid bird count',
      'err_invalid_date': 'Please enter a valid acquisition date',
      'err_failed': 'Failed to save flock. Please try again.',
      'success_msg': 'Flock saved successfully!',
      'update_success_msg': 'Flock updated successfully!',
    },
    'km': {
      'app_bar_title': 'បន្ថែមហ្វូងបក្សី',
      'banner_title': 'ចុះឈ្មោះបក្សីថ្មី',
      'banner_desc':
          'កត់ត្រាលម្អិតពីហ្វូងបក្សីរបស់អ្នក ដើម្បីតាមដានការចាក់វ៉ាក់សាំងឱ្យបានត្រឹមត្រូវ។',
      'lbl_batch_name': 'ឈ្មោះបក្សីសរុប',
      'hint_batch_name': 'ឧទាហរណ៍៖ មាន់ជង្រុកខាងជើង ០១',
      'lbl_bird_count': 'ចំនួនក្បាល',
      'lbl_date': 'កាលបរិច្ឆេទទទួលបាន',
      'lbl_breed': 'ពូជ / ប្រភេទ',
      'breed_broiler': 'មាន់សាច់',
      'breed_layer': 'មាន់ពង',
      'breed_local': 'ពូជក្នុងស្រុក',
      'guardian_title': 'ការត្រួតពិនិត្យរបស់អាណាព្យាបាល',
      'guardian_desc':
          'ការចុះឈ្មោះហ្វូងបក្សីរបស់អ្នក អនុញ្ញាតឱ្យប្រព័ន្ធបសុពេទ្យរបស់យើង បង្កើតកាលវិភាគចាក់វ៉ាក់សាំងដែលបានណែនាំដោយស្វ័យប្រវត្ត ដោយផ្អែកលើគោលការណ៍ណែនាំសុខភាពបសុបក្សីកម្ពុជា។',
      'btn_save': 'រក្សាទុក',
      'btn_save_edit': 'ធ្វើបច្ចុប្បន្នភាពហ្វូង',
      'btn_saving': 'កំពុងរក្សាទុក...',
      'btn_cancel': 'បោះបង់',
      'app_bar_title_edit': 'កែសម្រួលហ្វូងបក្សី',
      'banner_title_edit': 'បន្ទាន់សម័យព័ត៌មានហ្វូង',
      'err_empty_name': 'សូមបញ្ចូលឈ្មោះហ្វូងបក្សី',
      'err_invalid_count': 'សូមបញ្ចូលចំនួនបក្សីឲ្យបានត្រឹមត្រូវ',
      'err_invalid_date': 'សូមបញ្ចូលកាលបរិច្ឆេទទទួលបានឲ្យត្រឹមត្រូវ',
      'err_failed': 'ការរក្សាទុកបរាជ័យ។ សូមព្យាយាមម្តងទៀត។',
      'success_msg': 'រក្សាទុកហ្វូងបក្សីបានជោគជ័យ!',
    },
  };

  bool get _isEditing => widget.editingFlock != null;

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingFlock != null) {
      _batchNameController.text = widget.editingFlock!.batchName;
      _birdCountController.text = widget.editingFlock!.birdCount.toString();
      _selectedBreed = widget.editingFlock!.breed ?? 'Broiler';
      final parsedDate = DateTime.tryParse(widget.editingFlock!.dateAcquired);
      if (parsedDate != null) {
        _selectedDate = parsedDate;
      }
    }
    _dateController.text = _formatDisplayDate(_selectedDate);
  }

  String? _formatDateForBackend(String input) {
    if (input.isEmpty) return null;

    // Accept ISO-style input first.
    var normalized = input.trim();
    if (DateTime.tryParse(normalized) != null) {
      return DateTime.parse(normalized).toIso8601String().split('T').first;
    }

    // Accept dd/MM/yyyy or dd-MM-yyyy input.
    final separator = normalized.contains('/') ? '/' : '-';
    final parts = normalized.split(separator);
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final parsed = DateTime.tryParse(
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        );
        if (parsed != null) {
          return parsed.toIso8601String().split('T').first;
        }
      }
    }

    return null;
  }

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDisplayDate(picked);
      });
    }
  }

  // --- Helper to Pop back to Dashboard Home Root ---
  void _navigateToHomeDashboard() {
    if (mounted) {
      // Option A: Pops back to the first screen in the navigation stack (usually your Dashboard home)
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Option B: If you use named routes (e.g., '/home'), uncomment the line below instead:
      // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  // --- Backend API Integration Method ---
  Future<void> _saveFlockToBackend() async {
    final batchName = _batchNameController.text.trim();
    final birdCountText = _birdCountController.text.trim();
    final dateAcquired = _dateController.text.trim();

    // 1. Client-Side Validations
    if (batchName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_empty_name')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final birdCount = int.tryParse(birdCountText);
    if (birdCount == null || birdCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_invalid_count')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final backendDate = _formatDateForBackend(dateAcquired);
    if (backendDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_invalid_date')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final token = await StorageService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('err_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final url = widget.editingFlock == null
        ? Uri.parse('${ApiConfig.baseUrl}/flocks')
        : Uri.parse(
            '${ApiConfig.baseUrl}/flocks/${widget.editingFlock!.flockId}',
          );

    try {
      final response = await (widget.editingFlock == null
          ? http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'batch_name': batchName,
                'bird_count': birdCount,
                'date_acquired': backendDate,
                'breed': _selectedBreed,
              }),
            )
          : http.patch(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'batch_name': batchName,
                'bird_count': birdCount,
                'date_acquired': backendDate,
                'breed': _selectedBreed,
              }),
            ));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.editingFlock == null
                    ? _getText('success_msg')
                    : _getText('update_success_msg'),
              ),
              backgroundColor: brandHeaderGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          if (mounted) {
            GoRouter.of(
              context,
            ).go('/farmer-dashboard?lang=${widget.languageCode}&saved=true');
          }
        }
      } else {
        throw Exception('Server error');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('err_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _batchNameController.dispose();
    _birdCountController.dispose();
    _dateController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: brandDarkGreen),
          onPressed:
              _navigateToHomeDashboard, // Back arrow goes directly to Home
        ),
        title: Text(
          _getText(_isEditing ? 'app_bar_title_edit' : 'app_bar_title'),
          style: const TextStyle(
            color: brandDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: alertBgGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: alertBorderGreen, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: brandDarkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.egg_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText(
                              _isEditing ? 'banner_title_edit' : 'banner_title',
                            ),
                            style: const TextStyle(
                              color: brandDarkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getText('banner_desc'),
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
              ),
              const SizedBox(height: 24),

              // Form fields (Batch Name)
              Row(
                children: [
                  const Icon(
                    Icons.label_outline_rounded,
                    size: 16,
                    color: textGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getText('lbl_batch_name'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _batchNameController,
                enabled: !_isSaving,
                style: const TextStyle(color: textDarkBlue, fontSize: 15),
                decoration: InputDecoration(
                  hintText: _getText('hint_batch_name'),
                  hintStyle: const TextStyle(color: textGrey, fontSize: 15),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: textGreyLight,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: brandDarkGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Bird Count & Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.numbers_rounded,
                              size: 16,
                              color: textGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getText('lbl_bird_count'),
                              style: const TextStyle(
                                color: textDarkBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _birdCountController,
                          keyboardType: TextInputType.number,
                          enabled: !_isSaving,
                          style: const TextStyle(
                            color: textDarkBlue,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: textGreyLight,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: brandDarkGreen,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: textGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getText('lbl_date'),
                              style: const TextStyle(
                                color: textDarkBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateController,
                          readOnly: true,
                          enabled: !_isSaving,
                          onTap: _selectDate,
                          style: const TextStyle(
                            color: textDarkBlue,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: textGreyLight,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: brandDarkGreen,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Breed Card Grid Selector
              Row(
                children: [
                  const Icon(Icons.pets_rounded, size: 16, color: textGrey),
                  const SizedBox(width: 6),
                  Text(
                    _getText('lbl_breed'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildBreedCard(
                      id: 'Broiler',
                      label: _getText('breed_broiler'),
                      icon: Icons.restaurant_menu_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBreedCard(
                      id: 'Layer',
                      label: _getText('breed_layer'),
                      icon: Icons.egg_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBreedCard(
                      id: 'Local Breed',
                      label: _getText('breed_local'),
                      icon: Icons.eco_outlined,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 24),

              // Guardian Notice Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textGreyLight, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: brandHeaderGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText('guardian_title'),
                            style: const TextStyle(
                              color: brandDarkGreen,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getText('guardian_desc'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons (Save & Cancel)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _saveFlockToBackend, // Triggers Save + Route clean up
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    _isSaving
                        ? _getText('btn_saving')
                        : _getText(_isEditing ? 'btn_save_edit' : 'btn_save'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDarkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : _navigateToHomeDashboard, // Cancels and returns to Home
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandDarkGreen,
                    side: const BorderSide(color: brandDarkGreen, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getText('btn_cancel'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBreedCard({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedBreed == id;

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _selectedBreed = id;
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? brandDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brandDarkGreen : textGreyLight,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textDarkBlue,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textDarkBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: brandDarkGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: brandDarkGreen,
                size: 26,
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined, size: 26),
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
