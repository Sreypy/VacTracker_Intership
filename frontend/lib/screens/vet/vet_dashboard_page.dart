import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/vet_dashboard_service.dart';
import '../../widgets/notification_header_button.dart';

class VetDashboardPage extends StatefulWidget {
  final String languageCode;
  final String? profileImageUrl;

  const VetDashboardPage({
    super.key,
    required this.languageCode,
    this.profileImageUrl,
  });

  @override
  State<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage> {
  int _currentIndex = 0;

  // Modern Color Palette
  static const Color primaryGreen = Color(0xFF0F5132);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color lightGreenBg = Color(0xFFECFDF5);
  static const Color backgroundSurface = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Status Colors
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusDangerBg = Color(0xFFFEF2F2);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningBg = Color(0xFFFFFBEB);
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusSuccessBg = Color(0xFFECFDF5);

  // Localization (English + Khmer)
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'greeting_morning': 'Good Morning',
      'greeting_afternoon': 'Good Afternoon',
      'greeting_evening': 'Good Evening',
      'veterinary_portal': 'Veterinary Portal',
      'banner_subtitle': 'Monitor assigned farmers & flock health status',
      'section_overview': 'Overview',
      'section_my_farmers': 'My Farmers',
      'action_view_all': 'View All',
      'metric_farmers': 'Farmers',
      'metric_total_flocks': 'Total Flocks',
      'metric_sick_reports': 'Sick Reports',
      'metric_resolved_reports': 'Resolved Reports',
      'unit_flocks': 'Flocks',
      'unit_birds': 'Birds',
      'nav_home': 'Home',
      'nav_reports': 'Reports',
      'nav_farmers': 'Farmers',
      'nav_profile': 'Profile',
      'error_title': 'Unable to load dashboard',
      'retry': 'Retry',
      'empty_farmers_title': 'No assigned farmers yet',
      'empty_farmers_subtitle': 'Farmers assigned to you will appear here.',
      'status_healthy': 'HEALTHY',
      'status_sick': 'SICK',
      'status_overdue': 'OVERDUE',
      'status_due_soon': 'DUE SOON',
    },
    'km': {
      'greeting_morning': 'អរុណសួស្តី',
      'greeting_afternoon': 'ទិវាសួស្តី',
      'greeting_evening': 'សាយណ្ហសួស្តី',
      'veterinary_portal': 'សេវាពេទ្យសត្វ',
      'banner_subtitle': 'ត្រួតពិនិត្យកសិករដែលបានកំណត់ និងសុខភាពហ្វូងបក្សី',
      'section_overview': 'បូកសរុប',
      'section_my_farmers': 'កសិកររបស់ខ្ញុំ',
      'action_view_all': 'មើលទាំងអស់',
      'metric_farmers': 'កសិករ',
      'metric_total_flocks': 'ចំនួនហ្វូង',
      'metric_sick_reports': 'របាយការណ៍សត្វឈឺ',
      'metric_resolved_reports': 'បានដោះស្រាយ',
      'unit_flocks': 'ហ្វូង',
      'unit_birds': 'ក្បាល',
      'nav_home': 'ទំព័រដើម',
      'nav_reports': 'របាយការណ៍',
      'nav_farmers': 'កសិករ',
      'nav_profile': 'ប្រវត្តិរូប',
      'error_title': 'មិនអាចផ្ទុកផ្ទាំងព័ត៌មានបានទេ',
      'retry': 'ព្យាយាមម្តងទៀត',
      'empty_farmers_title': 'មិនមានកសិករដែលបានកំណត់នៅឡើយទេ',
      'empty_farmers_subtitle': 'កសិករដែលបានកំណត់ឱ្យអ្នកនឹងបង្ហាញនៅទីនេះ។',
      'status_healthy': 'សុខភាពល្អ',
      'status_sick': 'មានសត្វឈឺ',
      'status_overdue': 'ហួសកំណត់',
      'status_due_soon': 'ជិតដល់ពេល',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  /// Localized per-farmer status badge label.
  /// English keeps the backend-provided `statusText` (e.g. "2 SICK REPORTS");
  /// Khmer maps from the status enum because backend text is English only.
  String _farmerStatusText(FarmerData farmer) {
    if (widget.languageCode != 'km') return farmer.statusText;
    switch (farmer.status) {
      case 'sick':
        return _getText('status_sick');
      case 'overdue':
        return _getText('status_overdue');
      case 'due_soon':
        return _getText('status_due_soon');
      case 'healthy':
      default:
        return _getText('status_healthy');
    }
  }

  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;
  String _vetName = 'Dr. Sokha';
  String _vetInitials = 'S';

  final VetDashboardService _vetDashboardService = VetDashboardService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchVetProfile();
    _fetchDashboardStats();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return _getText('greeting_morning');
    if (hour < 17) return _getText('greeting_afternoon');
    return _getText('greeting_evening');
  }

  Future<void> _fetchVetProfile() async {
    try {
      final profile = await _authService.getProfile();
      if (!mounted) return;
      final name = profile['name']?.toString() ?? 'Dr. Sokha';
      setState(() {
        _vetName = name;
        if (name.isNotEmpty) {
          final nameParts = name.trim().split(' ');
          if (nameParts.length >= 2) {
            _vetInitials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
          } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
            _vetInitials = nameParts[0][0].toUpperCase();
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _fetchDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _vetDashboardService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _dashboardStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSurface,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryGreen,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await _fetchVetProfile();
            await _fetchDashboardStats();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeaderBanner(),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      _buildLoadingView()
                    else if (_errorMessage != null)
                      _buildErrorView()
                    else ...[
                      _buildSectionHeader(_getText('section_overview')),
                      const SizedBox(height: 12),
                      _buildMetricsGrid(),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                        _getText('section_my_farmers'),
                        actionText: _getText('action_view_all'),
                        onActionTap: () =>
                            context.push('/my-farmers/${widget.languageCode}'),
                      ),
                      const SizedBox(height: 12),
                      if (_dashboardStats?.farmers.isEmpty ?? true)
                        _buildEmptyFarmersState()
                      else
                        ..._dashboardStats!.farmers.map(_buildFarmerCard),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cardSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: 20,
      centerTitle: false,
      actions: [
        NotificationHeaderButton(
          languageCode: widget.languageCode,
          color: textPrimary,
          showCount: true,
          notificationsRoute: '/vet-notifications',
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderSubtle, height: 1),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryGreen.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: lightGreenBg,
              backgroundImage:
                  widget.profileImageUrl != null &&
                      widget.profileImageUrl!.isNotEmpty
                  ? NetworkImage(widget.profileImageUrl!)
                  : null,
              child:
                  widget.profileImageUrl == null ||
                      widget.profileImageUrl!.isEmpty
                  ? Text(
                      _vetInitials,
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "VacTracker",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                _getText('veterinary_portal'),
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreen, Color(0xFF145A32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$_vetName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getText('banner_subtitle'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              children: [
                Text(
                  actionText,
                  style: const TextStyle(
                    color: accentGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: accentGreen,
                  size: 18,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          icon: Icons.people_alt_outlined,
          label: _getText('metric_farmers'),
          value: '${_dashboardStats?.connectedFarmers ?? 0}',
          iconBgColor: lightGreenBg,
          iconColor: primaryGreen,
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.pets_outlined,
          label: _getText('metric_total_flocks'),
          value: '${_dashboardStats?.totalFlocks ?? 0}',
          iconBgColor: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.medical_services_outlined,
          label: _getText('metric_sick_reports'),
          value: '${_dashboardStats?.newSickReports ?? 0}',
          iconBgColor: statusDangerBg,
          iconColor: statusDanger,
          isAlert: (_dashboardStats?.newSickReports ?? 0) > 0,
          onTap: () => context.push('/vet-reports?lang=${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.check_circle_outline_rounded,
          label: _getText('metric_resolved_reports'),
          value: '${_dashboardStats?.resolvedReports ?? 0}',
          iconBgColor: statusSuccessBg,
          iconColor: statusSuccess,
          onTap: () => context.push(
            '/vet-reports?lang=${widget.languageCode}&status=resolved',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
    required Color iconColor,
    bool isAlert = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAlert ? iconColor.withValues(alpha: 0.4) : borderSubtle,
          width: isAlert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    if (isAlert)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isAlert ? iconColor : textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

  Widget _buildFarmerCard(FarmerData farmer) {
    Color statusFg;
    Color statusBg;

    switch (farmer.status) {
      case 'sick':
      case 'overdue':
        statusFg = statusDanger;
        statusBg = statusDangerBg;
        break;
      case 'due_soon':
        statusFg = statusWarning;
        statusBg = statusWarningBg;
        break;
      case 'healthy':
      default:
        statusFg = statusSuccess;
        statusBg = statusSuccessBg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push(
            '/farmer-detail/${farmer.farmerId}/${widget.languageCode}',
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // FIXED: Inner Row with Flexible wraps to prevent overflow
                      Row(
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            size: 13,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${farmer.flockCount} ${_getText('unit_flocks')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          ),
                          const Icon(
                            Icons.pets_rounded,
                            size: 13,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${farmer.totalBirds} ${_getText('unit_birds')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _farmerStatusText(farmer),
                    style: TextStyle(
                      color: statusFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: cardSurface,
        border: Border(top: BorderSide(color: borderSubtle, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go('/vet-dashboard?lang=${widget.languageCode}');
              break;
            case 1:
              context.go('/vet-reports?lang=${widget.languageCode}');
              break;
            case 2:
              context.go('/my-farmers/${widget.languageCode}');
              break;
            case 3:
              context.go('/vet-profile/${widget.languageCode}');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined, size: 24),
            activeIcon: const Icon(Icons.home_rounded, size: 24),
            label: _getText('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined, size: 24),
            activeIcon: const Icon(Icons.assignment_rounded, size: 24),
            label: _getText('nav_reports'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline_rounded, size: 24),
            activeIcon: const Icon(Icons.people_rounded, size: 24),
            label: _getText('nav_farmers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded, size: 24),
            activeIcon: const Icon(Icons.person_rounded, size: 24),
            label: _getText('nav_profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80.0),
      child: Center(
        child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 3),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: statusDangerBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: statusDanger,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _getText('error_title'),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage!,
            style: const TextStyle(color: textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _fetchDashboardStats,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(_getText('retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFarmersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: backgroundSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_off_outlined,
              color: textMuted,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _getText('empty_farmers_title'),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getText('empty_farmers_subtitle'),
            style: const TextStyle(color: textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
