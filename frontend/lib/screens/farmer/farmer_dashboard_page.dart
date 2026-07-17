import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:go_router/go_router.dart';

class FarmerDashboardPage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'
  final bool showSavedMessage;
  final String? profileImageUrl; // Pass null or network URL string

  const FarmerDashboardPage({
    super.key,
    required this.languageCode,
    this.showSavedMessage = false,
    this.profileImageUrl,
  });

  @override
  State<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends State<FarmerDashboardPage> {
  int _currentIndex = 2;
  final FlockService _flockService = FlockService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Flock> _flocks = [];

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  static const Color statusGreen = Color(0xFF107C41);
  static const Color statusGreenBg = Color(0xFFE2F6EA);
  static const Color statusYellow = Color(0xFFB78209);
  static const Color statusYellowBg = Color(0xFFFFF7E5);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusRedBg = Color(0xFFFDE8E8);

  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'greeting': 'Hello, Sovann',
      'subtitle': 'Monitoring your poultry health status.',
      'total_birds': 'Total Birds',
      'month_growth': '+12% this month',
      'healthy': 'Healthy',
      'upcoming': 'Upcoming',
      'overdue': 'Overdue',
      'vet_warning': 'Not linked to a vet yet',
      'vet_tap': 'Tap to connect',
      'section_title': 'Your Flocks',
      'view_history': 'View History',
      'up_to_date': 'Up to date',
      'due_tomorrow': 'Due Tomorrow',
      'broilers': 'Broilers',
      'layers': 'Layers',
      'breeder': 'Breeder',
      'birds': 'Birds',
      'day': 'Day',
      'success_msg': 'Flock saved successfully!',
    },
    'km': {
      'greeting': 'សួស្តី សុវណ្ណ',
      'subtitle': 'កំពុងតាមដានស្ថានភាពសុខភាពបក្សីរបស់អ្នក។',
      'total_birds': 'បក្សីសរុប',
      'month_growth': '+12% ខែនេះ',
      'healthy': 'សុខភាពល្អ',
      'upcoming': 'ជិតដល់ពេល',
      'overdue': 'ហួសកំណត់',
      'vet_warning': 'មិនទាន់ភ្ជាប់ទៅបសុពេទ្យទេ',
      'vet_tap': 'ប៉ះដើម្បីភ្ជាប់ទំនាក់ទំនង',
      'section_title': 'ហ្វូងបក្សីរបស់អ្នក',
      'view_history': 'មើលប្រវត្តិ',
      'up_to_date': 'ទាន់សម័យ',
      'due_tomorrow': 'ដល់កំណត់ថ្ងៃស្អែក',
      'broilers': 'មាន់សាច់',
      'layers': 'មាន់ពង',
      'breeder': 'មាន់ពូជ',
      'birds': 'ក្បាល',
      'day': 'ថ្ងៃទី',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadFlocks();
    if (widget.showSavedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('success_msg')),
            backgroundColor: brandHeaderGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant FarmerDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showSavedMessage != widget.showSavedMessage ||
        oldWidget.languageCode != widget.languageCode) {
      _loadFlocks();
    }
  }

  Future<void> _loadFlocks() async {
    try {
      final flocks = await _flockService.fetchFlocks();
      if (!mounted) return;
      setState(() {
        _flocks = flocks;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteFlock(int flockId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flock'),
          content: const Text('Are you sure you want to delete this flock?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isLoading = true;
      });
      await _flockService.deleteFlock(flockId);
      if (!mounted) return;
      await _loadFlocks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flock deleted successfully.'),
          backgroundColor: Color(0xFF047857),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete flock. ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEditFlock(Flock flock) {
    context.push('/add-flock/${widget.languageCode}', extra: flock);
  }

  String _getFlockStatus(Flock flock) {
    final ageDays = flock.ageInDays;
    if (ageDays <= 30) {
      return _getText('up_to_date');
    }
    if (ageDays <= 45) {
      return _getText('due_tomorrow');
    }
    return _getText('overdue');
  }

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  // Dynamic Avatar Loader Helper
  Widget _buildUserAvatar(String? avatarUrl, String displayName) {
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: hasAvatar
          ? Colors.transparent
          : brandHeaderGreen.withOpacity(0.15),
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: hasAvatar
          ? null
          : Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
              style: const TextStyle(
                color: brandDarkGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            _buildUserAvatar(
              widget.profileImageUrl,
              "Sovann",
            ), // Profile Image Dynamic Avatar
            const SizedBox(width: 10),
            const Text(
              "VacTracker",
              style: TextStyle(
                color: brandDarkGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_outlined,
              color: brandDarkGreen,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-flock/${widget.languageCode}');
        },
        backgroundColor: brandDarkGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('greeting'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getText('subtitle'),
                style: const TextStyle(color: textGrey, fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Birds Metrics Dashboard Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getText('total_birds'),
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "1,240",
                              style: TextStyle(
                                color: brandDarkGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: brandDarkGreen,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _getText('month_growth'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSubMetric(
                          _getText('healthy'),
                          "98%",
                          statusGreen,
                        ),
                        _buildSubMetric(
                          _getText('upcoming'),
                          "4",
                          brandHeaderGreen,
                        ),
                        _buildSubMetric(_getText('overdue'), "1", statusRed),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alert Vet Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEECEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.report_problem_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText('vet_warning'),
                            style: const TextStyle(
                              color: Color(0xFF7F1D1D),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _getText('vet_tap'),
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFDC2626),
                                size: 11,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getText('section_title'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      _getText('view_history'),
                      style: const TextStyle(
                        color: brandHeaderGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 24),
              ] else if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFF991B1B)),
                  ),
                ),
                const SizedBox(height: 24),
              ] else if (_flocks.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_getText('section_title')} is empty. Add your first flock now.',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                for (final flock in _flocks) ...[
                  _buildFlockCard(
                    flock: flock,
                    batchName: flock.batchName,
                    subtitle:
                        '${flock.birdCount} ${_getText('birds')} • ${_getText('day')} ${flock.ageInDays}',
                    statusText: _getFlockStatus(flock),
                    accentColor: flock.ageInDays <= 30
                        ? statusGreen
                        : flock.ageInDays <= 45
                        ? statusYellow
                        : statusRed,
                    statusColor: flock.ageInDays <= 30
                        ? statusGreen
                        : flock.ageInDays <= 45
                        ? statusYellow
                        : statusRed,
                    statusBgColor: flock.ageInDays <= 30
                        ? statusGreenBg
                        : flock.ageInDays <= 45
                        ? statusYellowBg
                        : statusRedBg,
                    onEdit: () => _navigateToEditFlock(flock),
                    onDelete: () => _confirmDeleteFlock(flock.flockId),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSubMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFlockCard({
    required Flock flock,
    required String batchName,
    required String subtitle,
    required String statusText,
    required Color accentColor,
    required Color statusColor,
    required Color statusBgColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store_mall_directory_outlined,
                  color: brandDarkGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batchName,
                      style: const TextStyle(
                        color: textDarkBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: brandDarkGreen,
                    tooltip: 'Edit',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: const Color(0xFFB91C1C),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey.withOpacity(0.6),
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
                color: brandDarkGreen.withOpacity(0.12),
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
