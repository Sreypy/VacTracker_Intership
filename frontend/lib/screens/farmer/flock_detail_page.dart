import 'package:flutter/material.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/flock_service.dart';
import 'package:frontend/services/vaccination_service.dart';
import 'package:go_router/go_router.dart';

class FlockDetailPage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'
  final String batchTitle;
  final Flock? flock;

  const FlockDetailPage({
    super.key,
    required this.languageCode,
    this.batchTitle = 'Batch A-102',
    this.flock,
  });

  @override
  State<FlockDetailPage> createState() => _FlockDetailPageState();
}

class _FlockDetailPageState extends State<FlockDetailPage> {
  int _currentIndex = 2;
  final FlockService _flockService = FlockService();
  final VaccinationService _vaccinationService = VaccinationService();
  bool _isLoading = true;
  String? _errorMessage;
  Flock? _flock;
  List<Map<String, dynamic>> _vaccinationHistory = [];

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);

  static const Color alertRedBg = Color(0xFFFDF2F2);
  static const Color alertRedText = Color(0xFFC5221F);
  static const Color alertRedBorder = Color(0xFFF87171);

  static const Color statusGreen = Color(0xFF107C41);
  static const Color statusGreenBg = Color(0xFFE2F6EA);
  static const Color statusYellow = Color(0xFFB78209);
  static const Color statusYellowBg = Color(0xFFFFF7E5);

  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'lbl_current_status': 'CURRENT STATUS',
      'lbl_due_badge': 'Due in 2 days',
      'title_upcoming': 'Upcoming Vaccination',
      'desc_upcoming': 'Vaccination due soon',
      'tag_layer': 'Layer Chicks',
      'tag_birds': 'Birds',
      'btn_log_vaccination': 'Log vaccination',
      'btn_flag_sick': 'Flag sick/dead',
      'btn_view_history': 'View full history',
      'section_recent_history': 'Recent History',
      'btn_see_all': 'See All',
      'banner_title': 'Protect Your Yield',
      'banner_desc': 'Follow the recommended schedule for maximum flock health.',
      'disease_ibv': 'IBV (Gumboro)',
      'disease_marek': 'Marek\'s Disease',
      'disease_salmonella': 'Salmonella Type A',
      'age': 'Age',
      'breed': 'Breed',
      'date_acquired': 'Date Acquired',
      'health_status': 'Health Status',
      'healthy': 'Healthy',
      'no_vaccinations': 'No vaccination history',
      'vaccination_date': 'Date',
      'vaccine': 'Vaccine',
      'status': 'Status',
    },
    'km': {
      'lbl_current_status': 'ស្ថានភាពបច្ចុប្បន្ន',
      'lbl_due_badge': 'ដល់កំណត់ក្នុង 2 ថ្ងៃ',
      'title_upcoming': 'ការចាក់វ៉ាក់សាំងខាងមុខ',
      'desc_upcoming': 'ការចាក់វ៉ាក់សាំងជិតដល់',
      'tag_layer': 'កូនមាន់ពង',
      'tag_birds': 'ក្បាល',
      'btn_log_vaccination': 'កត់ត្រាការចាក់វ៉ាក់សាំង',
      'btn_flag_sick': 'រាយការណ៍ឈឺ/ងាប់',
      'btn_view_history': 'មើលប្រវត្តិទាំងស្រុង',
      'section_recent_history': 'ប្រវត្តិថ្មីៗ',
      'btn_see_all': 'មើលទាំងអស់',
      'banner_title': 'ការពារទិន្នផលរបស់អ្នក',
      'banner_desc': 'អនុវត្តតាមកាលវិភាគដែលបានណែនាំ ដើម្បីសុខភាពហ្វូងបក្សីល្អបំផុត។',
      'disease_ibv': 'ជំងឺអាសន្នរោគបក្សី (Gumboro)',
      'disease_marek': 'ជំងឺម៉ារ៉ែក (Marek\'s)',
      'disease_salmonella': 'ជំងឺសាល់ម៉ូណេឡា ប្រភេទ A',
      'age': 'អាយុ',
      'breed': 'ប្រភេទ',
      'date_acquired': 'កាលបរិច្ឆេទទិញ',
      'health_status': 'ស្ថានភាពសុខភាព',
      'healthy': 'សុខភាពល្អ',
      'no_vaccinations': 'មិនមានប្រវត្តិការចាក់វ៉ាក់សាំង',
      'vaccination_date': 'កាលបរិច្ឆេទ',
      'vaccine': 'វ៉ាក់សាំង',
      'status': 'ស្ថានភាព',
    },
  };

  String _getText(String key) {
    final lang = widget.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  @override
  void initState() {
    super.initState();
    _loadFlockData();
  }

  Future<void> _loadFlockData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // If flock object is passed directly, use it
      if (widget.flock != null) {
        _flock = widget.flock;
      } else {
        // Otherwise fetch by batch title (simplified - in real app would use ID)
        // For now, we'll fetch all flocks and find the matching one
        final flocks = await _flockService.fetchFlocks();
        final matchingFlock = flocks.firstWhere(
          (f) => f.batchName == widget.batchTitle,
          orElse: () => flocks.isNotEmpty ? flocks.first : Flock(
            flockId: 0,
            batchName: widget.batchTitle,
            birdCount: 0,
            age: 0,
            ageUnit: 'days',
            breed: 'Unknown',
            dateAcquired: DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        _flock = matchingFlock;
      }

      // Fetch vaccination history for this flock
      if (_flock != null && _flock!.flockId > 0) {
        try {
          final vaccinations = await _vaccinationService.fetchVaccinationsByFlock(_flock!.flockId);
          final history = <Map<String, dynamic>>[];
          
          for (var v in vaccinations) {
            // Skip if v is not a Map
            if (v is! Map<String, dynamic>) continue;
            
            final dateGiven = v['date_given'] != null 
                ? DateTime.tryParse(v['date_given'].toString()) 
                : null;
            if (dateGiven != null) {
              final vaccine = v['vaccine'] as Map<String, dynamic>? ?? {};
              history.add({
                'date': dateGiven,
                'vaccine_name': vaccine['name']?.toString() ?? 'Unknown Vaccine',
                'status': v['status']?.toString() ?? 'on_time',
                'next_due': v['next_due_date'] != null 
                    ? DateTime.tryParse(v['next_due_date'].toString()) 
                    : null,
              });
            }
          }
          
          // Sort by date descending
          if (history.isNotEmpty) {
            history.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
          }
          
          if (!mounted) return;
          setState(() {
            _vaccinationHistory = history.take(5).toList();
          });
        } catch (e) {
          // If vaccination fetch fails, continue with empty history
          if (!mounted) return;
          setState(() {
            _vaccinationHistory = [];
          });
        }
      }

      if (!mounted) return;
      setState(() {
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'on_time':
        return _getText('lbl_due_badge');
      case 'due_soon':
        return 'Due Soon';
      case 'overdue':
        return 'Overdue';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on_time':
        return statusGreen;
      case 'due_soon':
        return statusYellow;
      case 'overdue':
        return alertRedText;
      default:
        return textGrey;
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _flock != null ? _flock!.batchName : widget.batchTitle,
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
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 16,
            backgroundColor: textGreyLight,
            child: Icon(Icons.person, color: brandDarkGreen, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ] else if (_flock != null) ...[
                // 1. Current Status Card
                _buildStatusCard(),
                const SizedBox(height: 16),

                // 2. Primary Action Button
                _buildPrimaryActionButton(),
                const SizedBox(height: 14),

                // 3. Secondary Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryActionButton(
                        icon: Icons.warning_amber_rounded,
                        label: _getText('btn_flag_sick'),
                        color: alertRedText,
                        borderColor: alertRedBorder.withValues(alpha: 0.5),
                        bgColor: Colors.white,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSecondaryActionButton(
                        icon: Icons.history_rounded,
                        label: _getText('btn_view_history'),
                        color: brandDarkGreen,
                        borderColor: textGreyLight,
                        bgColor: Colors.white,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Recent History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getText('section_recent_history'),
                      style: const TextStyle(
                        color: textDarkBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        _getText('btn_see_all'),
                        style: const TextStyle(
                          color: brandDarkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_vaccinationHistory.isEmpty)
                  _buildEmptyHistory()
                else
                  ..._vaccinationHistory.map((vaccination) {
                    final date = vaccination['date'] as DateTime?;
                    final status = vaccination['status'] as String? ?? 'on_time';
                    final vaccineName = vaccination['vaccine_name'] as String? ?? 'Unknown Vaccine';
                    
                    if (date == null) return null;
                    
                    return _buildHistoryTile(
                      title: vaccineName,
                      dateTime: '${_formatDate(date)} • ${_getStatusText(status)}',
                      statusColor: _getStatusColor(status),
                    );
                  }).whereType<Widget>(),

                const SizedBox(height: 20),

                // 5. Promotional Bottom Card
                _buildPromoBannerCard(),

                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatusCard() {
    if (_flock == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textGreyLight, width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final ageDays = _flock!.ageInDays;
    final isDueSoon = ageDays > 30 && ageDays <= 45;
    final isOverdue = ageDays > 45;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGreyLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Indicator Bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isOverdue ? alertRedText : isDueSoon ? statusYellow : statusGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getText('lbl_current_status'),
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue ? alertRedBg : isDueSoon ? statusYellowBg : statusGreenBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isOverdue ? Icons.warning_amber_outlined : Icons.check_circle_outlined,
                                size: 13,
                                color: isOverdue ? alertRedText : isDueSoon ? statusYellow : statusGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOverdue ? 'Overdue' : isDueSoon ? 'Due Soon' : 'Healthy',
                                style: TextStyle(
                                  color: isOverdue ? alertRedText : isDueSoon ? statusYellow : statusGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title & Description
                    Text(
                      _flock!.batchName,
                      style: TextStyle(
                        color: isOverdue ? alertRedText : textDarkBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_flock!.birdCount} ${_getText('tag_birds')} • ${_flock!.breed ?? 'Unknown Breed'}',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Info Tags
                    Row(
                      children: [
                        _buildInfoTag(
                          icon: Icons.calendar_today_outlined,
                          label: '${_flock!.ageInDays} ${_getText('day')}',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoTag(
                          icon: Icons.groups_outlined,
                          label: '${_flock!.birdCount} ${_getText('tag_birds')}',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: textGreyLight.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.health_and_safety_outlined,
                            size: 16,
                            color: isOverdue ? alertRedText : statusGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: brandDarkGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: textDarkBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    return InkWell(
      onTap: () {
        context.push('/log-vaccination-step1/${widget.languageCode}');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: brandDarkGreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: brandDarkGreen.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.vaccines, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              _getText('btn_log_vaccination'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile({required String title, required String dateTime, Color statusColor = statusGreen}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusGreenBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: statusGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDarkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  style: const TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textGrey, size: 22),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: textGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            _getText('no_vaccinations'),
            style: TextStyle(
              color: textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            brandDarkGreen.withValues(alpha: 0.9),
            brandDarkGreen.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getText('banner_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getText('banner_desc'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
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