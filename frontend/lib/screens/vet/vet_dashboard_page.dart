import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color statusGreen = Color(0xFF0D6E28);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusRedBg = Color(0xFFFDE8E8);
  static const Color statusYellow = Color(0xFFB78209);

  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;
  final VetDashboardService _vetDashboardService = VetDashboardService();

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _vetDashboardService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
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
              backgroundColor: brandHeaderGreen.withValues(alpha: 0.15),
              child: Text(
                "S",
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
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Good Morning,',
                style: TextStyle(color: textGrey, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                'Dr. Sokha 👋',
                style: TextStyle(
                  color: textDarkBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor your farmers and poultry health',
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Loading or Error State
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: brandDarkGreen),
                  ),
                )
              else if (_errorMessage != null)
                Center(
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
                          'Unable to load dashboard',
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
                          onPressed: _fetchDashboardStats,
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
                )
              else ...[
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        '👨‍🌾',
                        'Connected Farmers',
                        '${_dashboardStats?.connectedFarmers ?? 0}',
                        'Farmers',
                        brandDarkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        '🐔',
                        'Total Flocks',
                        '${_dashboardStats?.totalFlocks ?? 0}',
                        'Flocks',
                        brandDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAlertCard(
                        '🩺',
                        'New Sick Reports',
                        '${_dashboardStats?.newSickReports ?? 0}',
                        'Reports',
                        statusRed,
                        statusRedBg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAlertCard(
                        '💉',
                        'Overdue Vaccinations',
                        '${_dashboardStats?.overdueVaccinations ?? 0}',
                        'Flocks',
                        statusRed,
                        statusRedBg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // My Farmers Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Farmers',
                      style: TextStyle(
                        color: textDarkBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Farmers List
                if (_dashboardStats != null)
                  ..._dashboardStats!.farmers.map((farmer) {
                    return _buildFarmerCard(farmer);
                  }).toList(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryCard(
    String emoji,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    String emoji,
    String label,
    String value,
    String unit,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildFarmerCard(FarmerData farmer) {
    // Determine status color and icon
    Color statusColor;
    String statusEmoji;

    switch (farmer.status) {
      case 'sick':
        statusColor = statusRed;
        statusEmoji = '🔴';
        break;
      case 'overdue':
        statusColor = statusRed;
        statusEmoji = '🔴';
        break;
      case 'due_soon':
        statusColor = statusYellow;
        statusEmoji = '🟡';
        break;
      case 'healthy':
      default:
        statusColor = statusGreen;
        statusEmoji = '🟢';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to farmer detail screen
          // context.push('/farmer-detail/${farmer.farmerId}?lang=${widget.languageCode}');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.name,
                      style: TextStyle(
                        color: textDarkBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farmer.flockCount} Flocks · ${farmer.totalBirds} Chickens',
                      style: TextStyle(color: textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(statusEmoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          farmer.statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: textGrey, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: textGreyLight, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            context.push('/vet-dashboard?lang=${widget.languageCode}');
          } else if (index == 1) {
            context.push('/vet-reports?lang=${widget.languageCode}');
          } else if (index == 2) {
            context.push('/my-farmers/${widget.languageCode}');
          } else if (index == 3) {
            context.push('/vet-profile/${widget.languageCode}');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, size: 24),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_outline_rounded,
              size: 24,
              color: _currentIndex == 2 ? brandDarkGreen : null,
            ),
            label: 'Farmers',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
