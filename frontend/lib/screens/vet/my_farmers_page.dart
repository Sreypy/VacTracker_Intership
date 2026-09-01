import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/vet_dashboard_service.dart';

class MyFarmersPage extends StatefulWidget {
  final String languageCode;
  final String? profileImageUrl;

  const MyFarmersPage({
    super.key,
    required this.languageCode,
    this.profileImageUrl,
  });

  @override
  State<MyFarmersPage> createState() => _MyFarmersPageState();
}

class _MyFarmersPageState extends State<MyFarmersPage> {
  // Color Palette Constants
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);

  // Status Badge Colors
  static const Color statusRed = Color(0xFFDC2626);
  static const Color statusRedBg = Color(0xFFFEF2F2);
  static const Color statusYellow = Color(0xFFD97706);
  static const Color statusYellowBg = Color(0xFFFFFBEB);
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusGreenBg = Color(0xFFF0FDF4);

  final TextEditingController _searchController = TextEditingController();
  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _vetInitials = 'S';

  final VetDashboardService _vetDashboardService = VetDashboardService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchVetProfile();
    _fetchDashboardStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVetProfile() async {
    try {
      final profile = await _authService.getProfile();
      if (!mounted) return;
      final name = profile['name']?.toString() ?? 'Dr. Sokha';
      setState(() {
        if (name.isNotEmpty) {
          final nameParts = name.trim().split(' ');
          if (nameParts.length >= 2) {
            _vetInitials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
          } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
            _vetInitials = nameParts[0][0].toUpperCase();
          }
        }
      });
    } catch (_) {
      // Retain fallback default
    }
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

  List<FarmerData> get _filteredFarmers {
    if (_dashboardStats == null) return [];
    if (_searchQuery.trim().isEmpty) return _dashboardStats!.farmers;

    final query = _searchQuery.toLowerCase().trim();
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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 20,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderGrey),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: brandHeaderGreen.withAlpha(30),
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
                        color: brandDarkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Text(
              "VacTracker",
              style: TextStyle(
                color: brandDarkGreen,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.notifications_none_rounded,
        //       color: textDarkBlue,
        //       size: 26,
        //     ),
        //     onPressed: () {
        //       context.push('/notifications/${widget.languageCode}');
        //     },
        //   ),
        //   const SizedBox(width: 12),
        // ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search Box (Fixed Top Area)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Farmers',
                        style: TextStyle(
                          color: textDarkBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_dashboardStats != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: brandHeaderGreen.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_dashboardStats!.farmers.length} Total',
                            style: const TextStyle(
                              color: brandHeaderGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Farmers and operations connected to your account',
                    style: TextStyle(color: textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar Input
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderGrey),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: textDarkBlue, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by farmer, farm name, or location...',
                        hintStyle: TextStyle(
                          color: textGrey.withAlpha(180),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: textGrey,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: textGrey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
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
            const Divider(height: 1, color: borderGrey),

            // Farmers Dynamic List Content
            Expanded(
              child: RefreshIndicator(
                color: brandDarkGreen,
                onRefresh: () async {
                  await _fetchVetProfile();
                  await _fetchDashboardStats();
                },
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: brandDarkGreen),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: statusRed,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load farmers',
                    style: TextStyle(
                      color: textDarkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: textGrey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchDashboardStats,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final farmers = _filteredFarmers;

    if (farmers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.people_outline_rounded
                        : Icons.search_off_rounded,
                    size: 56,
                    color: textGrey.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No farmers connected yet'
                        : 'No matching results',
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Farmers will appear here when they link their app using your unique practitioner code.'
                        : 'No farmer or location matched "$_searchQuery". Try searching with a different term.',
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        return _buildFarmerCard(farmers[index]);
      },
    );
  }

  Widget _buildFarmerCard(FarmerData farmer) {
    Color statusFg;
    Color statusBg;

    switch (farmer.status) {
      case 'sick':
      case 'overdue':
        statusFg = statusRed;
        statusBg = statusRedBg;
        break;
      case 'due_soon':
        statusFg = statusYellow;
        statusBg = statusYellowBg;
        break;
      case 'healthy':
      default:
        statusFg = statusGreen;
        statusBg = statusGreenBg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '/farmer-detail/${farmer.farmerId}/${widget.languageCode}',
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: textDarkBlue,
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
                            color: textDarkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          farmer.farmName,
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
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
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: borderGrey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: textGrey,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        farmer.location,
                        style: const TextStyle(color: textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.pets_outlined,
                        color: textGrey,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${farmer.flockCount} Flocks (${farmer.totalBirds} Birds)',
                        style: const TextStyle(
                          color: textDarkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: borderGrey, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/vet-dashboard?lang=${widget.languageCode}');
          } else if (index == 1) {
            context.go('/vet-reports?lang=${widget.languageCode}');
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
