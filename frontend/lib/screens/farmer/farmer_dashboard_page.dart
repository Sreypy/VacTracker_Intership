import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/services/vaccination_service.dart';
import 'package:frontend/services/storage_service.dart';
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
  final VaccinationService _vaccinationService = VaccinationService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Flock> _flocks = [];
  String _userName = '';
  // Dashboard metrics
  int _totalFlocks = 0;
  int _totalBirds = 0;
  int _healthyFlocks = 0;
  int _overdueFlocks = 0;
  int _upcomingVaccinations = 0;
  int _overdueVaccinations = 0;
  List<Map<String, dynamic>> _recentVaccinations = [];

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
      'greeting_prefix': 'Hello,',
      'greeting': 'Hello, farmer',
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
      'due_tomorrow': 'Due Soon',
      'overdue_status': 'Overdue',
      'broilers': 'Broilers',
      'layers': 'Layers',
      'breeder': 'Breeder',
      'birds': 'Birds',
      'day': 'Day',
      'success_msg': 'Flock saved successfully!',
      'vaccinations_due': 'Vaccinations Due',
      'recent_activity': 'Recent Activity',
      'no_vaccinations': 'No recent vaccinations',
      'flock_health': 'Flock Health',
      'vaccination_status': 'Vaccination Status',
      'total_flocks': 'Total Flocks',
      'healthy_flocks': 'Healthy',
      'overdue_flocks': 'Overdue',
      'upcoming_vaccinations': 'Upcoming',
      'overdue_vaccinations': 'Overdue',
      'view_all': 'View All',
      'days': 'days',
      'weeks': 'weeks',
      'months': 'months',
    },
    'km': {
      'greeting_prefix': 'សួស្តី',
      'greeting': 'សួស្តី ម្ចាស់កសិដ្ឋាន',
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
      'due_tomorrow': 'ជិតដល់',
      'overdue_status': 'ហួសកំណត់',
      'broilers': 'មាន់សាច់',
      'layers': 'មាន់ពង',
      'breeder': 'មាន់ពូជ',
      'birds': 'ក្បាល',
      'day': 'ថ្ងៃទី',
      'success_msg': 'បានរក្សាទុកហ្វូងបក្សីដោយជោគជ័យ!',
      'vaccinations_due': 'ការចាក់វ៉ាក់សាំង',
      'recent_activity': 'សកម្មភាពថ្មីៗ',
      'no_vaccinations': 'មិនមានការចាក់វ៉ាក់សាំងថ្មី',
      'flock_health': 'សុខភាពហ្វូង',
      'vaccination_status': 'ស្ថានភាពវ៉ាក់សាំង',
      'total_flocks': 'ចំនួនហ្វូងសរុប',
      'healthy_flocks': 'សុខភាពល្អ',
      'overdue_flocks': 'ហួសកំណត់',
      'upcoming_vaccinations': 'ជិតដល់',
      'overdue_vaccinations': 'ហួសកំណត់',
      'view_all': 'មើលទាំងអស់',
      'days': 'ថ្ងៃ',
      'weeks': 'សប្តាហ៍',
      'months': 'ខែ',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadDashboardData();
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
      _loadDashboardData();
      _loadUserName();
    }
  }

  Future<void> _loadUserName() async {
    final userName = await StorageService.getName();
    if (!mounted) return;
    setState(() {
      _userName = userName?.trim() ?? '';
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch flocks and all vaccinations in parallel
      final flocksFuture = _flockService.fetchFlocks();
      final vaccinationsFuture = _vaccinationService.fetchAllVaccinations();

      final results = await Future.wait([flocksFuture, vaccinationsFuture]);
      final flocks = results[0] as List<Flock>;
      final vaccinations = results[1];

      // Calculate metrics
      final totalFlocks = flocks.length;
      final totalBirds = flocks.fold<int>(0, (s, f) => s + (f.birdCount));
      final healthyFlocks = flocks.where((f) => f.ageInDays <= 30).length;
      final overdueFlocks = flocks.where((f) => f.ageInDays > 45).length;

      // Process vaccination data
      final now = DateTime.now();
      int upcomingVaccinations = 0;
      int overdueVaccinations = 0;
      final recentVaccinations = <Map<String, dynamic>>[];

      for (var v in vaccinations) {
        final nextDueDate = v['next_due_date'] != null
            ? DateTime.tryParse(v['next_due_date'])
            : null;

        if (nextDueDate != null) {
          final daysUntilDue = nextDueDate.difference(now).inDays;
          if (daysUntilDue < 0) {
            overdueVaccinations++;
          } else if (daysUntilDue <= 7) {
            upcomingVaccinations++;
          }
        }

        // Get recent vaccinations (last 5)
        if (recentVaccinations.length < 5) {
          final dateGiven = v['date_given'] != null
              ? DateTime.tryParse(v['date_given'])
              : null;
          if (dateGiven != null) {
            recentVaccinations.add({
              'date': dateGiven,
              'flock_name': v['flock']?['batch_name'] ?? 'Unknown Fllock',
              'vaccine_name': v['vaccine']?['name'] ?? 'Unknown Vaccine',
              'status': v['status'] ?? 'on_time',
            });
          }
        }
      }

      // Sort recent vaccinations by date (most recent first)
      recentVaccinations.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );

      if (!mounted) return;

      setState(() {
        _flocks = flocks;
        _errorMessage = null;
        _totalFlocks = totalFlocks;
        _totalBirds = totalBirds;
        _healthyFlocks = healthyFlocks;
        _overdueFlocks = overdueFlocks;
        _upcomingVaccinations = upcomingVaccinations;
        _overdueVaccinations = overdueVaccinations;
        _recentVaccinations = recentVaccinations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
          title: Text(_getText('section_title')),
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
      await _loadDashboardData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('success_msg')),
          backgroundColor: const Color(0xFF047857),
          duration: const Duration(seconds: 2),
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

  void _navigateToFlockDetail(Flock flock) {
    context.push('/flock-detail/${widget.languageCode}', extra: flock);
  }

  String _getFlockStatus(Flock flock) {
    final ageDays = flock.ageInDays;
    if (ageDays <= 30) {
      return _getText('up_to_date');
    }
    if (ageDays <= 45) {
      return _getText('due_tomorrow');
    }
    return _getText('overdue_status');
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
          : brandHeaderGreen.withValues(alpha: 0.15),
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
              _userName.isNotEmpty ? _userName : "U",
            ),
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
              // Greeting
              Text(
                _userName.isNotEmpty
                    ? '${_getText('greeting_prefix')} $_userName'
                    : _getText('greeting'),
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
              ] else ...[
                // Main Metrics Grid
                _buildMetricsGrid(),
                const SizedBox(height: 16),

                // Vaccination Alerts Card
                if (_overdueVaccinations > 0 || _upcomingVaccinations > 0)
                  _buildVaccinationAlertCard(),
                if (_overdueVaccinations > 0 || _upcomingVaccinations > 0)
                  const SizedBox(height: 16),

                // Recent Activity Section
                if (_recentVaccinations.isNotEmpty) ...[
                  _buildSectionHeader(
                    _getText('recent_activity'),
                    _getText('view_all'),
                  ),
                  const SizedBox(height: 10),
                  _buildRecentActivityList(),
                  const SizedBox(height: 16),
                ],

                // Flocks Section
                _buildSectionHeader(
                  _getText('section_title'),
                  _getText('view_history'),
                ),
                const SizedBox(height: 10),
                if (_flocks.isEmpty) ...[
                  _buildEmptyState(),
                  const SizedBox(height: 80),
                ] else ...[
                  for (final flock in _flocks) ...[
                    _buildFlockCard(flock),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 80),
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        // Row 1: Total Birds and Total Flocks
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: _getText('total_birds'),
                value: _totalBirds.toString(),
                subtitle: _getText('total_flocks'),
                subtitleValue: _totalFlocks.toString(),
                icon: Icons.pets_outlined,
                color: brandDarkGreen,
                bgColor: const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: _getText('flock_health'),
                value: _totalFlocks > 0
                    ? '${((_healthyFlocks / _totalFlocks) * 100).round()}%'
                    : '0%',
                subtitle: _getText('healthy_flocks'),
                subtitleValue: '$_healthyFlocks/$_totalFlocks',
                icon: Icons.health_and_safety_outlined,
                color: statusGreen,
                bgColor: statusGreenBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Vaccination Status
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: _getText('vaccination_status'),
                value: _upcomingVaccinations.toString(),
                subtitle: _getText('upcoming_vaccinations'),
                subtitleValue: '$_upcomingVaccinations',
                icon: Icons.calendar_today_outlined,
                color: statusYellow,
                bgColor: statusYellowBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: _getText('overdue_flocks'),
                value: _overdueFlocks.toString(),
                subtitle: _getText('overdue_vaccinations'),
                subtitleValue: '$_overdueVaccinations',
                icon: Icons.warning_amber_outlined,
                color: _overdueFlocks > 0 ? statusRed : textGrey,
                bgColor: _overdueFlocks > 0
                    ? statusRedBg
                    : const Color(0xFFF1F5F9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required String subtitleValue,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(subtitle, style: TextStyle(color: textGrey, fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                subtitleValue,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationAlertCard() {
    final hasOverdue = _overdueVaccinations > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasOverdue ? const Color(0xFFFEECEB) : const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasOverdue ? const Color(0xFFEF4444) : const Color(0xFFB78209),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasOverdue
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFB78209),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
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
                  hasOverdue
                      ? '${_getText('overdue_vaccinations')}: $_overdueVaccinations'
                      : '${_getText('upcoming_vaccinations')}: $_upcomingVaccinations',
                  style: TextStyle(
                    color: hasOverdue
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFF78350F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasOverdue
                      ? 'Action required: Some vaccinations are overdue'
                      : 'Vaccinations due within the next 7 days',
                  style: TextStyle(
                    color: hasOverdue
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFB78209),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: hasOverdue
                ? const Color(0xFFDC2626)
                : const Color(0xFFB78209),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDarkBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            actionText,
            style: const TextStyle(
              color: brandHeaderGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _recentVaccinations.map((vaccination) {
          final date = vaccination['date'] as DateTime;
          final status = vaccination['status'] as String;
          final isOnTime = status == 'on_time';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOnTime ? statusGreenBg : statusYellowBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.vaccines_outlined,
                    color: isOnTime ? statusGreen : statusYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination['vaccine_name'] as String,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vaccination['flock_name'] as String,
                        style: const TextStyle(color: textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOnTime ? statusGreenBg : statusYellowBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOnTime ? 'On Time' : 'Due Soon',
                        style: TextStyle(
                          color: isOnTime ? statusGreen : statusYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(color: textGrey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: textGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '${_getText('section_title')} is empty',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first flock to get started',
            style: TextStyle(color: textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFlockCard(Flock flock) {
    final statusText = _getFlockStatus(flock);
    final accentColor = flock.ageInDays <= 30
        ? statusGreen
        : flock.ageInDays <= 45
        ? statusYellow
        : statusRed;
    final statusColor = accentColor;
    final statusBgColor = flock.ageInDays <= 30
        ? statusGreenBg
        : flock.ageInDays <= 45
        ? statusYellowBg
        : statusRedBg;

    return InkWell(
      onTap: () => _navigateToFlockDetail(flock),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
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
                  child: Icon(
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
                        flock.batchName,
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${flock.birdCount} ${_getText('birds')} • ${_getText('day')} $flock.ageInDays',
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
                      onPressed: () => _navigateToEditFlock(flock),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: const Color(0xFFB91C1C),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDeleteFlock(flock.flockId),
                    ),
                  ],
                ),
              ],
            ),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            context.push('/log-vaccination-step1/${widget.languageCode}');
            return;
          }
          if (index == 4) {
            context.push('/farmer-profile/${widget.languageCode}');
            return;
          }
          if (index == 0) {
            context.push('/notifications/${widget.languageCode}');
            return;
          }
          setState(() => _currentIndex = index);
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
