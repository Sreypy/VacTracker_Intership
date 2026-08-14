import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/vet_dashboard_service.dart';

class MyFarmersPage extends StatefulWidget {
  final String languageCode;

  const MyFarmersPage({super.key, required this.languageCode});

  @override
  State<MyFarmersPage> createState() => _MyFarmersPageState();
}

class _MyFarmersPageState extends State<MyFarmersPage> {
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color statusGreen = Color(0xFF0D6E28);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusYellow = Color(0xFFB78209);

  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
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

  List<FarmerData> get _filteredFarmers {
    if (_dashboardStats == null) return [];
    if (_searchQuery.isEmpty) return _dashboardStats!.farmers;

    final query = _searchQuery.toLowerCase();
    return _dashboardStats!.farmers.where((farmer) {
      return farmer.name.toLowerCase().contains(query) ||
          farmer.farmName.toLowerCase().contains(query) ||
          farmer.location.toLowerCase().contains(query);
    }).toList();
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
                    'My Farmers',
                    style: TextStyle(
                      color: textDarkBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Farmers connected to you',
                    style: TextStyle(color: textGrey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textGreyLight, width: 1),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search farmer or farm',
                        hintStyle: TextStyle(
                          color: textGrey.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: textGrey.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: brandDarkGreen,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Farmers List
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
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
                'Unable to load farmers',
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
      );
    }

    final farmers = _filteredFarmers;

    if (farmers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: textGrey.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No farmers connected yet'
                    : 'No farmers found',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Farmers will appear here when they connect using your share code',
                  style: TextStyle(
                    color: textGrey.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        return _buildFarmerCard(farmers[index]);
      },
    );
  }

  Widget _buildFarmerCard(FarmerData farmer) {
    // Determine status color and emoji
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
                  context.push('/farmer-detail/${farmer.farmerId}/${widget.languageCode}');
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
                    const SizedBox(height: 2),
                    Text(
                      farmer.farmName,
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      farmer.location,
                      style: TextStyle(color: textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${farmer.flockCount} Flocks · ${farmer.totalBirds} Chickens',
                          style: TextStyle(color: textGrey, fontSize: 11),
                        ),
                      ],
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.push('/vet-dashboard/${widget.languageCode}');
          } else if (index == 1) {
            context.push('/vet-reports/${widget.languageCode}');
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
