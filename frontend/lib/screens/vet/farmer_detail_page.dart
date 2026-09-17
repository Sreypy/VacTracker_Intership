import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/farmer_detail_service.dart';
import '../../widgets/notification_header_button.dart';

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
  static const Color warningOrange = Color(0xFFD97706);
  static const Color warningOrangeBg = Color(0xFFFFFBEB);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFF0FDF4);

  // Localization (English + Khmer)
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'tab_overview': 'Overview',
      'tab_flocks': 'Flocks',
      'tab_vaccines': 'Vaccines',
      'tab_reports': 'Reports',
      'label_owner': 'Owner',
      'label_phone': 'Phone',
      'metric_total_chickens': 'Total Chickens',
      'metric_total_flocks': 'Total Flocks',
      'metric_sick_reports': 'Sick Reports',
      'metric_vaccines_due': 'Vaccines Due',
      'metric_vaccines_completed': 'Vaccines Completed',

      'total_chickens': 'Total Chickens',
      'total_active_flocks': 'Total Active Flocks',
      'active_sick_reports': 'Active Sick Reports',
      'pending_vaccinations': 'Pending Vaccinations',
      'no_flocks': 'No flocks registered',
      'chickens': 'Chickens',
      'no_vaccines': 'No vaccine records',
      'label_flock': 'Flock',
      'label_given': 'Given',
      'label_next_due': 'Next Due',
      'status_due_soon': 'Due Soon',
      'status_overdue': 'Overdue',
      'status_completed': 'Completed',
      'status_up_to_date': 'Up to Date',
      'no_sick_reports': 'No sick reports',
      'affected_label': 'Affected',
      'load_failed': 'Failed to load details',
      'retry': 'Retry',
    },
    'km': {
      'tab_overview': 'បូកសរុប',
      'tab_flocks': 'ហ្វូង',
      'tab_vaccines': 'វ៉ាក់សាំង',
      'tab_reports': 'របាយការណ៍',
      'label_owner': 'ម្ចាស់',
      'label_phone': 'លេខទូរស័ព្ទ',
      'metric_total_chickens': 'បក្សីសរុប',
      'metric_total_flocks': 'ចំនួនហ្វូងសរុប',
      'metric_sick_reports': 'របាយការណ៍សត្វឈឺ',
      'metric_vaccines_due': 'ការចាក់វ៉ាក់សាំង',
      'metric_vaccines_completed': 'វ៉ាក់សាំងបានចាក់',
      'total_chickens': 'បក្សីសរុប',
      'total_active_flocks': 'ហ្វូងសកម្មសរុប',
      'active_sick_reports': 'របាយការណ៍សត្វឈឺសកម្ម',
      'pending_vaccinations': 'ការចាក់វ៉ាក់សាំងដែលចាំបាច់',
      'no_flocks': 'មិនមានហ្វូងបក្សីបានចុះឈ្មោះ',
      'chickens': 'ក្បាល',
      'no_vaccines': 'មិនមានកំណត់ត្រាវ៉ាក់សាំង',
      'label_flock': 'ហ្វូង',
      'label_given': 'ចាក់បាន',
      'label_next_due': 'កំណត់បន្ទាប់',
      'status_due_soon': 'ជិតដល់ពេល',
      'status_overdue': 'ហួសកំណត់',
      'status_completed': 'បានបញ្ចប់',
      'status_up_to_date': 'ទាន់ពេល',
      'no_sick_reports': 'មិនមានរបាយការណ៍សត្វឈឺ',
      'affected_label': 'សត្វរងផលប៉ះពាល់',
      'load_failed': 'មិនអាចផ្ទុកព័ត៌មានបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

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
                            letterSpacing: 0.2,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          tabs: [
                            Tab(text: _getText('tab_overview')),
                            Tab(text: _getText('tab_flocks')),
                            Tab(text: _getText('tab_vaccines')),
                            Tab(text: _getText('tab_reports')),
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
      actions: [
        NotificationHeaderButton(
          languageCode: widget.languageCode,
          color: textMain,
          notificationsRoute: '/vet-notifications',
        ),
        const SizedBox(width: 6),
      ],
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
                label: _getText('label_owner'),
                value: farm.farmer.name,
              ),
              _buildCompactInfoTile(
                icon: Icons.smartphone_outlined,
                label: _getText('label_phone'),
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
    final completedVaccines = _farmerDetail!.vaccinations
        .where((v) => v.status.toLowerCase() == 'completed')
        .length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildMetricCard(
          title: _getText('metric_total_chickens'),
          value: '${summary.totalChickens}',
          icon: Icons.pets_outlined,
          color: primaryGreen,
          bgColor: primaryLight,
          onTap: () => _tabController.animateTo(1),
        ),
        _buildMetricCard(
          title: _getText('metric_total_flocks'),
          value: '${summary.totalFlocks}',
          icon: Icons.grid_view_outlined,
          color: primaryGreen,
          bgColor: primaryLight,
          onTap: () => _tabController.animateTo(1),
        ),
        _buildMetricCard(
          title: _getText('metric_sick_reports'),
          value: '${summary.activeSickReports}',
          icon: Icons.medical_information_outlined,
          color: summary.activeSickReports > 0 ? alertRed : successGreen,
          bgColor: summary.activeSickReports > 0 ? alertRedBg : successGreenBg,
          onTap: () => _tabController.animateTo(3),
        ),
        _buildMetricCard(
          title: _getText('metric_vaccines_completed'),
          value: '$completedVaccines',
          icon: Icons.check_circle_outline,
          color: successGreen,
          bgColor: successGreenBg,
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
              _buildListRow(
                _getText('total_chickens'),
                '${summary.totalChickens}',
              ),
              const Divider(height: 24, color: cardBorder),
              _buildListRow(
                _getText('total_active_flocks'),
                '${summary.totalFlocks}',
              ),
              const Divider(height: 24, color: cardBorder),
              _buildListRow(
                _getText('active_sick_reports'),
                '${summary.activeSickReports}',
              ),
              const Divider(height: 24, color: cardBorder),
              _buildListRow(
                _getText('pending_vaccinations'),
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
    if (_farmerDetail!.flocks.isEmpty) {
      return _buildEmptyState(_getText('no_flocks'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.flocks.length,
      itemBuilder: (context, index) {
        final flock = _farmerDetail!.flocks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
              subtitle: Text(
                '${flock.birdCount} ${_getText('chickens')} • ${flock.breed}',
                style: const TextStyle(color: textMuted),
              ),
              // trailing: const Icon(Icons.chevron_right, color: textMuted),
              onTap: () => context.push(
                '/flock-detail/${flock.flockId}/${widget.languageCode}',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    if (_farmerDetail!.vaccinations.isEmpty) {
      return _buildEmptyState(_getText('no_vaccines'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.vaccinations.length,
      itemBuilder: (context, index) {
        final vax = _farmerDetail!.vaccinations[index];
        final vaxStatus = _vaccinationStatusStyle(vax.status);
        final nextDueText = vax.nextDueDate == null
            ? '—'
            : _formatDate(vax.nextDueDate!);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
                '/flock-detail/${vax.flockId}/${widget.languageCode}',
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryLight,
                          child: Icon(
                            Icons.vaccines_outlined,
                            color: primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vax.vaccineName,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildVaccinationStatusBadge(vaxStatus),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: cardBorder),
                    const SizedBox(height: 10),
                    _buildVaccinationInfoRow(
                      icon: Icons.groups_outlined,
                      label: '${_getText('label_flock')}:',
                      value: vax.flockName,
                    ),
                    const SizedBox(height: 4),
                    _buildVaccinationInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: '${_getText('label_given')}:',
                      value: _formatDate(vax.dateGiven),
                    ),
                    const SizedBox(height: 4),
                    _buildVaccinationInfoRow(
                      icon: Icons.schedule_outlined,
                      label: '${_getText('label_next_due')}:',
                      value: nextDueText,
                      valueColor: vax.nextDueDate == null
                          ? textMuted
                          : vaxStatus.fgColor,
                      valueWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w500,
  }) {
    return Row(
      children: [
        Icon(icon, color: textMuted, size: 14),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? textMain,
              fontSize: 13,
              fontWeight: valueWeight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  _VaccinationStatusStyle _vaccinationStatusStyle(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'due_soon':
        return _VaccinationStatusStyle(
          label: _getText('status_due_soon'),
          fgColor: warningOrange,
          bgColor: warningOrangeBg,
          icon: Icons.warning_amber_rounded,
        );
      case 'overdue':
        return _VaccinationStatusStyle(
          label: _getText('status_overdue'),
          fgColor: alertRed,
          bgColor: alertRedBg,
          icon: Icons.error_outline,
        );
      case 'completed':
        return _VaccinationStatusStyle(
          label: _getText('status_completed'),
          fgColor: successGreen,
          bgColor: successGreenBg,
          icon: Icons.check_circle_outline,
        );
      case 'on_time':
      default:
        return _VaccinationStatusStyle(
          label: _getText('status_up_to_date'),
          fgColor: successGreen,
          bgColor: successGreenBg,
          icon: Icons.check_circle_outline,
        );
    }
  }

  Widget _buildVaccinationStatusBadge(_VaccinationStatusStyle vaxStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: vaxStatus.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(vaxStatus.icon, color: vaxStatus.fgColor, size: 12),
          const SizedBox(width: 4),
          Text(
            vaxStatus.label,
            style: TextStyle(
              color: vaxStatus.fgColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSickReportsTab() {
    if (_farmerDetail!.sickReports.isEmpty) {
      return _buildEmptyState(_getText('no_sick_reports'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmerDetail!.sickReports.length,
      itemBuilder: (context, index) {
        final report = _farmerDetail!.sickReports[index];
        final isResolved = report.status == 'resolved';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
                '${report.reportType.toUpperCase()} • ${_getText('affected_label')} ${report.affectedCount}',
                style: const TextStyle(color: textMuted),
              ),
              trailing: const Icon(Icons.chevron_right, color: textMuted),
              onTap: () => context.push(
                '/vet-reports/${report.reportId}?lang=${widget.languageCode}',
              ),
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
            Text(
              _getText('load_failed'),
              style: const TextStyle(
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
              label: Text(_getText('retry')),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _VaccinationStatusStyle {
  final String label;
  final Color fgColor;
  final Color bgColor;
  final IconData icon;

  _VaccinationStatusStyle({
    required this.label,
    required this.fgColor,
    required this.bgColor,
    required this.icon,
  });
}
