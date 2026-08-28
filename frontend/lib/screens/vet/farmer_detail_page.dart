import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/farmer_detail_service.dart';

class FarmerDetailPage extends StatefulWidget {
  final int farmerId;
  final String languageCode;

  const FarmerDetailPage({
    super.key,
    required this.farmerId,
    required this.languageCode,
  });

  @override
  State<FarmerDetailPage> createState() => _FarmerDetailPageState();
}

class _FarmerDetailPageState extends State<FarmerDetailPage>
    with SingleTickerProviderStateMixin {
  // Theme Color System
  static const Color primaryGreen = Color(0xFF025920);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color surfaceBg = Color(0xFFF4F6F8);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE2E8F0);

  static const Color alertRed = Color(0xFFDC2626);
  static const Color alertRedBg = Color(0xFFFEF2F2);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFF0FDF4);

  late TabController _tabController;
  FarmerDetail? _farmerDetail;
  bool _isLoading = true;
  String? _errorMessage;
  String _vetInitials = 'S';

  final FarmerDetailService _farmerDetailService = FarmerDetailService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchVetProfile();
    _fetchFarmerDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchVetProfile() async {
    try {
      final profile = await _authService.getProfile();
      if (!mounted) return;
      final name = profile['name']?.toString() ?? 'Dr. Sokha';
      setState(() {
        if (name.isNotEmpty) {
          final parts = name.trim().split(' ');
          if (parts.length >= 2) {
            _vetInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else if (parts.isNotEmpty) {
            _vetInitials = parts[0][0].toUpperCase();
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _fetchFarmerDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _farmerDetailService.getFarmerDetail(
        widget.farmerId,
      );
      if (!mounted) return;
      setState(() {
        _farmerDetail = detail;
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
      backgroundColor: surfaceBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : _errorMessage != null
            ? _buildErrorView()
            : DefaultTabController(
                length: 4,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            _buildFarmHeroCard(),
                            const SizedBox(height: 16),
                            _buildMetricsSection(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: primaryGreen,
                          unselectedLabelColor: textMuted,
                          indicatorColor: primaryGreen,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Flocks'),
                            Tab(text: 'Vaccines'),
                            Tab(text: 'Reports'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildFlocksTab(),
                      _buildVaccinationsTab(),
                      _buildSickReportsTab(),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primaryLight,
            child: Text(
              _vetInitials,
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'VacTracker',
            style: TextStyle(
              color: textMain,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.notifications_none_rounded, color: textMain),
      //     onPressed: () =>
      //         context.push('/notifications/${widget.languageCode}'),
      //   ),
      //   const SizedBox(width: 8),
      // ],
    );
  }

  Widget _buildFarmHeroCard() {
    if (_farmerDetail == null) return const SizedBox.shrink();
    final farm = _farmerDetail!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${farm.farmer.village}, ${farm.farmer.province}',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryLight,
                child: IconButton(
                  icon: const Icon(Icons.phone, color: primaryGreen, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: cardBorder),
          ),
          Row(
            children: [
              _buildCompactInfoTile(
                icon: Icons.person_outline,
                label: 'Owner',
                value: farm.farmer.name,
              ),
              _buildCompactInfoTile(
                icon: Icons.smartphone_outlined,
                label: 'Phone',
                value: farm.farmer.phone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: textMuted),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textMain,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    if (_farmerDetail == null) return const SizedBox.shrink();
    final summary = _farmerDetail!.summary;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildMetricCard(
          title: 'Total Chickens',
          value: '${summary.totalChickens}',
          icon: Icons.pets_outlined,
          color: primaryGreen,
          bgColor: primaryLight,
          onTap: () => _tabController.animateTo(1),
        ),
        _buildMetricCard(
          title: 'Total Flocks',
          value: '${summary.totalFlocks}',
          icon: Icons.grid_view_outlined,
          color: primaryGreen,
          bgColor: primaryLight,
          onTap: () => _tabController.animateTo(1),
        ),
        _buildMetricCard(
          title: 'Sick Reports',
          value: '${summary.activeSickReports}',
          icon: Icons.medical_information_outlined,
          color: summary.activeSickReports > 0 ? alertRed : successGreen,
          bgColor: summary.activeSickReports > 0 ? alertRedBg : successGreenBg,
          onTap: () => _tabController.animateTo(3),
        ),
        _buildMetricCard(
          title: 'Vaccines Due',
          value: '${summary.vaccinationsDue}',
          icon: Icons.vaccines_outlined,
          color: summary.vaccinationsDue > 0 ? alertRed : successGreen,
          bgColor: summary.vaccinationsDue > 0 ? alertRedBg : successGreenBg,
          onTap: () => _tabController.animateTo(2),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, color: textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_farmerDetail == null) return const SizedBox.shrink();
    final summary = _farmerDetail!.summary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              _buildListRow('Total Chickens', '${summary.totalChickens}'),
              const Divider(height: 24, color: cardBorder),
              _buildListRow('Total Active Flocks', '${summary.totalFlocks}'),
              const Divider(height: 24, color: cardBorder),
              _buildListRow(
                'Active Sick Reports',
                '${summary.activeSickReports}',
              ),
              const Divider(height: 24, color: cardBorder),
              _buildListRow(
                'Pending Vaccinations',
                '${summary.vaccinationsDue}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: textMain,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFlocksTab() {
    if (_farmerDetail!.flocks.isEmpty)
      return _buildEmptyState('No flocks registered');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.flocks.length,
      itemBuilder: (context, index) {
        final flock = _farmerDetail!.flocks[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: cardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: primaryLight,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: primaryGreen,
                size: 20,
              ),
            ),
            title: Text(
              flock.batchName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            subtitle: Text('${flock.birdCount} Chickens • ${flock.breed}'),
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: () => context.push(
              '/flock-detail/${flock.flockId}/${widget.languageCode}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    if (_farmerDetail!.vaccinations.isEmpty)
      return _buildEmptyState('No vaccine records');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.vaccinations.length,
      itemBuilder: (context, index) {
        final vax = _farmerDetail!.vaccinations[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: cardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: primaryLight,
              child: const Icon(
                Icons.vaccines_outlined,
                color: primaryGreen,
                size: 20,
              ),
            ),
            title: Text(
              vax.vaccineName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            subtitle: Text(
              'Flock: ${vax.flockName}\nDate: ${_formatDate(vax.dateGiven)}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: () => context.push(
              '/flock-detail/${vax.flockId}/${widget.languageCode}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildSickReportsTab() {
    if (_farmerDetail!.sickReports.isEmpty)
      return _buildEmptyState('No sick reports');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.sickReports.length,
      itemBuilder: (context, index) {
        final report = _farmerDetail!.sickReports[index];
        final isResolved =
            report.status == 'resolved' || report.status == 'reviewed';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: cardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: isResolved ? successGreenBg : alertRedBg,
              child: Icon(
                isResolved
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: isResolved ? successGreen : alertRed,
                size: 20,
              ),
            ),
            title: Text(
              report.flockName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            subtitle: Text(
              '${report.reportType.toUpperCase()} • ${report.affectedCount} Affected',
            ),
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: () => context.push(
              '/vet-reports/${report.reportId}?lang=${widget.languageCode}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: alertRed, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchFarmerDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: cardBorder)),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          final routes = [
            '/vet-dashboard?lang=${widget.languageCode}',
            '/vet-reports?lang=${widget.languageCode}',
            '/my-farmers/${widget.languageCode}',
            '/vet-profile/${widget.languageCode}',
          ];
          context.go(routes[index]);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Farmers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
