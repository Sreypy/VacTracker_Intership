import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/vet_dashboard_service.dart';

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
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color accentGreen = Color(0xFF198754);
  static const Color backgroundSurface = Color(0xFFF8FAF8);
  static const Color cardSurface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Status Colors
  static const Color statusDanger = Color(0xFFDC2626);
  static const Color statusDangerBg = Color(0xFFFEF2F2);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusWarningBg = Color(0xFFFFFBEB);
  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusSuccessBg = Color(0xFFF0FDF4);

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
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryGreen,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      _buildErrorView()
                    else ...[
                      _buildSectionTitle('Overview'),
                      const SizedBox(height: 12),
                      _buildMetricsGrid(),
                      const SizedBox(height: 28),
                      _buildFarmerHeader(),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "VacTracker",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                "Veterinary Portal",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      // actions: [
      //   Stack(
      //     alignment: Alignment.center,
      //     children: [
      //       IconButton(
      //         icon: const Icon(
      //           Icons.notifications_outlined,
      //           color: textPrimary,
      //           size: 24,
      //         ),
      //         onPressed: () =>
      //             context.push('/notifications/${widget.languageCode}'),
      //       ),
      //       Positioned(
      //         top: 10,
      //         right: 12,
      //         child: Container(
      //           width: 8,
      //           height: 8,
      //           decoration: const BoxDecoration(
      //             color: statusDanger,
      //             shape: BoxShape.circle,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      //   const SizedBox(width: 12),
      // ],
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreen, Color(0xFF145A32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_vetName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor your assigned farmers & poultry health',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          icon: Icons.people_alt_outlined,
          label: 'Farmers',
          value: '${_dashboardStats?.connectedFarmers ?? 0}',
          iconBgColor: lightGreenBg,
          iconColor: primaryGreen,
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.pets_outlined,
          label: 'Total Flocks',
          value: '${_dashboardStats?.totalFlocks ?? 0}',
          iconBgColor: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.medical_services_outlined,
          label: 'Sick Reports',
          value: '${_dashboardStats?.newSickReports ?? 0}',
          iconBgColor: statusDangerBg,
          iconColor: statusDanger,
          isAlert: (_dashboardStats?.newSickReports ?? 0) > 0,
          onTap: () => context.push('/vet-reports?lang=${widget.languageCode}'),
        ),
        _buildMetricCard(
          icon: Icons.vaccines_outlined,
          label: 'Overdue Vaccines',
          value: '${_dashboardStats?.overdueVaccinations ?? 0}',
          iconBgColor: statusWarningBg,
          iconColor: statusWarning,
          isAlert: (_dashboardStats?.overdueVaccinations ?? 0) > 0,
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? iconColor.withValues(alpha: 0.3) : borderSubtle,
          width: isAlert ? 1.5 : 1,
        ),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: isAlert ? iconColor : textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildFarmerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('My Farmers'),
        GestureDetector(
          onTap: () => context.push('/my-farmers/${widget.languageCode}'),
          child: const Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, color: accentGreen, size: 16),
            ],
          ),
        ),
      ],
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: backgroundSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.grid_view,
                            size: 12,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${farmer.flockCount} Flocks',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.pets, size: 12, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${farmer.totalBirds} Birds',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    farmer.statusText,
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, size: 24),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded, size: 24),
            label: 'Farmers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 12),
          const Text(
            'Unable to load dashboard',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: const TextStyle(color: textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchDashboardStats,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: backgroundSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_off_outlined,
              color: textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No assigned farmers yet',
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Farmers assigned to you will appear here.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
