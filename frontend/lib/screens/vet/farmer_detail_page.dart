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
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color statusGreen = Color(0xFF0D6E28);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusRedBg = Color(0xFFFDE8E8);

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

  Future<void> _fetchVetProfile() async {
    try {
      final profile = await _authService.getProfile();
      if (!mounted) return;
      final name = profile['name']?.toString() ?? 'Dr. Sokha';
      setState(() {
        if (name.isNotEmpty) {
          final nameParts = name.split(' ');
          if (nameParts.length >= 2) {
            _vetInitials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
          } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
            _vetInitials = nameParts[0][0].toUpperCase();
          }
        }
      });
    } catch (e) {
      // Keep default values if profile fetch fails
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      setState(() {
        _farmerDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
        titleSpacing: 16,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: textGreyLight),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: brandDarkGreen.withValues(alpha: 0.15),
              child: Text(
                _vetInitials,
                style: TextStyle(
                  color: brandDarkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              Icons.notifications_outlined,
              color: brandDarkGreen,
              size: 24,
            ),
            onPressed: () {
              context.push('/notifications/${widget.languageCode}');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Details',
                    style: TextStyle(
                      color: textDarkBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Farm Name
                  if (_farmerDetail != null)
                    Text(
                      _farmerDetail!.farmName,
                      style: TextStyle(
                        color: textDarkBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Farmer Info
                  if (_farmerDetail != null) ...[
                    _buildInfoRow('Farmer:', _farmerDetail!.farmer.name),
                    const SizedBox(height: 4),
                    _buildInfoRow('Phone:', _farmerDetail!.farmer.phone),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      'Location:',
                      '${_farmerDetail!.farmer.village}, ${_farmerDetail!.farmer.province}',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Summary Cards
                  if (_farmerDetail != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            '🐔',
                            'Total Chickens',
                            '${_farmerDetail!.summary.totalChickens}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            '🐔',
                            'Total Flocks',
                            '${_farmerDetail!.summary.totalFlocks}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAlertCard(
                            '🩺',
                            'Sick Reports',
                            '${_farmerDetail!.summary.activeSickReports}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAlertCard(
                            '💉',
                            'Vaccinations Due',
                            '${_farmerDetail!.summary.vaccinationsDue}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textGreyLight, width: 1),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: brandDarkGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      labelColor: Colors.white,
                      unselectedLabelColor: textGrey,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(fontSize: 12),
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Flocks'),
                        Tab(text: 'Vaccinations'),
                        Tab(text: 'Sick Reports'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textDarkBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String emoji, String label, String value) {
    return InkWell(
      onTap: () {
        if (label == 'Total Flocks') {
          _tabController.animateTo(1); // Flocks tab
        } else if (label == 'Total Chickens') {
          _tabController.animateTo(1); // Flocks tab
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textGreyLight, width: 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: brandDarkGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: textGrey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String emoji, String label, String value) {
    final isAlert = int.tryParse(value) != null && int.parse(value) > 0;
    final color = isAlert ? statusRed : statusGreen;
    final bgColor = isAlert ? statusRedBg : const Color(0xFFDCFCE7);

    return InkWell(
      onTap: () {
        if (label == 'Sick Reports') {
          _tabController.animateTo(3); // Sick Reports tab
        } else if (label == 'Vaccinations Due') {
          _tabController.animateTo(2); // Vaccinations tab
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: brandDarkGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: statusRed,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load farmer details',
                style: TextStyle(
                  color: textDarkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchFarmerDetail,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandDarkGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_farmerDetail == null) {
      return const SizedBox.shrink();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildFlocksTab(),
        _buildVaccinationsTab(),
        _buildSickReportsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Overview',
            style: TextStyle(
              color: textDarkBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textGreyLight, width: 1),
            ),
            child: Column(
              children: [
                _buildOverviewRow(
                  'Total Chickens',
                  '${_farmerDetail!.summary.totalChickens}',
                ),
                const Divider(height: 24),
                _buildOverviewRow(
                  'Total Flocks',
                  '${_farmerDetail!.summary.totalFlocks}',
                ),
                const Divider(height: 24),
                _buildOverviewRow(
                  'Active Sick Reports',
                  '${_farmerDetail!.summary.activeSickReports}',
                ),
                const Divider(height: 24),
                _buildOverviewRow(
                  'Vaccinations Due',
                  '${_farmerDetail!.summary.vaccinationsDue}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textGrey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: textDarkBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFlocksTab() {
    if (_farmerDetail!.flocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No flocks found',
            style: TextStyle(color: textGrey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _farmerDetail!.flocks.length,
      itemBuilder: (context, index) {
        final flock = _farmerDetail!.flocks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textGreyLight, width: 1),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to flock detail
              context.push(
                '/flock-detail/${flock.flockId}/${widget.languageCode}',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flock.batchName,
                          style: TextStyle(
                            color: textDarkBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${flock.birdCount} chickens',
                          style: TextStyle(color: textGrey, fontSize: 13),
                        ),
                        if (flock.breed.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Breed: ${flock.breed}',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: textGrey,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    if (_farmerDetail!.vaccinations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No vaccinations found',
            style: TextStyle(color: textGrey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _farmerDetail!.vaccinations.length,
      itemBuilder: (context, index) {
        final vax = _farmerDetail!.vaccinations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textGreyLight, width: 1),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to flock detail
              context.push(
                '/flock-detail/${vax.flockId}/${widget.languageCode}',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vax.vaccineName,
                          style: TextStyle(
                            color: textDarkBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flock: ${vax.flockName}',
                          style: TextStyle(color: textGrey, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Given: ${_formatDate(vax.dateGiven)}',
                          style: TextStyle(color: textGrey, fontSize: 12),
                        ),
                        if (vax.nextDueDate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Next due: ${_formatDate(vax.nextDueDate!)}',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: textGrey,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSickReportsTab() {
    if (_farmerDetail!.sickReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No sick reports found',
            style: TextStyle(color: textGrey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _farmerDetail!.sickReports.length,
      itemBuilder: (context, index) {
        final report = _farmerDetail!.sickReports[index];
        final isNew = report.status == 'pending';
        final isResolved =
            report.status == 'resolved' || report.status == 'reviewed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textGreyLight, width: 1),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to sick report detail
              context.push(
                '/vet-reports/${report.reportId}?lang=${widget.languageCode}',
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isResolved
                          ? statusGreen.withValues(alpha: 0.1)
                          : statusRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isResolved
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: isResolved ? statusGreen : statusRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              report.flockName,
                              style: TextStyle(
                                color: textDarkBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.reportType.toUpperCase()} • ${report.affectedCount} chickens affected',
                          style: TextStyle(color: textGrey, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(report.createdAt),
                          style: TextStyle(color: textGrey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: textGrey,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: textGreyLight, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/vet-dashboard?lang=${widget.languageCode}');
          } else if (index == 1) {
            context.go('/vet-reports?lang=${widget.languageCode}');
          } else if (index == 2) {
            context.go('/my-farmers/${widget.languageCode}');
          } else if (index == 3) {
            context.go('/vet-profile/${widget.languageCode}');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey,
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
