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
  // Premium Design Tokens
  static const Color primaryGreen = Color(0xFF0D6E28);
  static const Color darkGreen = Color(0xFF034418);
  static const Color bgCanvas = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dynamic Status Tokens
  static const Color statusDangerFg = Color(0xFFDC2626);
  static const Color statusDangerBg = Color(0xFFFEF2F2);
  static const Color statusWarningFg = Color(0xFFD97706);
  static const Color statusWarningBg = Color(0xFFFFFBEB);
  static const Color statusSuccessFg = Color(0xFF16A34A);
  static const Color statusSuccessBg = Color(0xFFF0FDF4);

  // Localization (English + Khmer)
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title_my_farmers': 'My Farmers',
      'registered_count': 'Registered',
      'page_subtitle':
          'Farmers and operations currently assigned to your practice',
      'search_hint': 'Search by farmer, farm, or location...',
      'error_title': 'Failed to Load Farmers',
      'try_again': 'Try Again',
      'empty_no_farmers': 'No farmers registered',
      'empty_no_results': 'No results found',
      'empty_no_farmers_subtitle':
          'Farmers linked with your practitioner code will automatically show up here.',
      'empty_no_results_prefix': 'We couldn\'t find any records matching "',
      'empty_no_results_suffix': '".',
      'unit_flocks': 'Flocks',
      'unit_birds': 'Birds',
      'nav_home': 'Home',
      'nav_reports': 'Reports',
      'nav_farmers': 'Farmers',
      'nav_profile': 'Profile',
      'status_healthy': 'HEALTHY',
      'status_sick': 'SICK',
      'status_overdue': 'OVERDUE',
      'status_due_soon': 'DUE SOON',
      'requests_title': 'Connection Requests',
      'requests_empty': 'No pending requests',
      'accept': 'Accept',
      'reject': 'Reject',
      'request_accepted': 'Farmer connected!',
      'request_rejected': 'Request rejected',
      'requests_failed': 'Failed to update connection request',
    },
    'km': {
      'title_my_farmers': 'កសិកររបស់ខ្ញុំ',
      'registered_count': 'នាក់បានចុះឈ្មោះ',
      'page_subtitle': 'កសិករ និងអាជីវកម្មដែលត្រូវបានកំណត់ឱ្យអ្នកថែទាំ',
      'search_hint': 'ស្វែងរកតាមកសិករ ហ្វាំង ឬទីតាំង...',
      'error_title': 'មិនអាចផ្ទុកកសិករបានទេ',
      'try_again': 'ព្យាយាមម្តងទៀត',
      'empty_no_farmers': 'មិនមានកសិករបានចុះឈ្មោះ',
      'empty_no_results': 'រកមិនឃើញលទ្ធផល',
      'empty_no_farmers_subtitle':
          'កសិករដែលភ្ជាប់ជាមួយលេខកូដពេទ្យសត្វរបស់អ្នកនឹងបង្ហាញដោយស្វ័យប្រវត្តិនៅទីនេះ។',
      'empty_no_results_prefix': 'រកមិនឃើញកំណត់ត្រាណាមួយដែលត្រូវនឹង "',
      'empty_no_results_suffix': '" ទេ។',
      'unit_flocks': 'ហ្វូង',
      'unit_birds': 'ក្បាល',
      'nav_home': 'ទំព័រដើម',
      'nav_reports': 'របាយការណ៍',
      'nav_farmers': 'កសិករ',
      'nav_profile': 'ប្រវត្តិរូប',
      'status_healthy': 'សុខភាពល្អ',
      'status_sick': 'មានសត្វឈឺ',
      'status_overdue': 'ហួសកំណត់',
      'status_due_soon': 'ជិតដល់ពេល',
      'requests_title': 'សំណើភ្ជាប់',
      'requests_empty': 'មិនមានសំណើរង់ចាំ',
      'accept': 'ទទួលយក',
      'reject': 'បដិសេធ',
      'request_accepted': 'កសិករត្រូវបានភ្ជាប់ជោគជ័យ!',
      'request_rejected': 'បានបដិសេធសំណើ',
      'requests_failed': 'មិនអាចធ្វើបច្ចុប្បន្នភាពសំណើបាន',
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

  final TextEditingController _searchController = TextEditingController();
  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _vetInitials = 'S';

  // Farmer connection requests (PENDING connections for this vet)
  List<VetConnectionRequest> _connectionRequests = [];
  bool _isLoadingRequests = false;
  final Set<int> _respondingConnectionIds = {};

  final VetDashboardService _vetDashboardService = VetDashboardService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchVetProfile();
    _fetchDashboardStats();
    _fetchConnectionRequests();
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

  Future<void> _fetchConnectionRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });

    try {
      final requests = await _vetDashboardService.getConnectionRequests();
      if (!mounted) return;
      setState(() {
        _connectionRequests = requests;
        _isLoadingRequests = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRequests = false;
      });
    }
  }

  Future<void> _respondToConnection(int connectionId, bool accept) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _respondingConnectionIds.add(connectionId);
    });

    try {
      await _vetDashboardService.respondToConnection(connectionId, accept);
      if (!mounted) return;
      setState(() {
        _respondingConnectionIds.remove(connectionId);
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _getText(accept ? 'request_accepted' : 'request_rejected'),
          ),
          backgroundColor: accept ? primaryGreen : statusDangerFg,
        ),
      );
      await _fetchConnectionRequests();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _respondingConnectionIds.remove(connectionId);
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(_getText('requests_failed')),
          backgroundColor: statusDangerFg,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primaryGreen.withValues(alpha: 0.1),
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
                          color: darkGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "VacTracker",
              style: TextStyle(
                color: darkGreen,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderAndSearchSection(),
            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
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
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeaderAndSearchSection() {
    return Container(
      color: surfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _getText('title_my_farmers'),
                style: const TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              if (_dashboardStats != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_dashboardStats!.farmers.length} ${_getText('registered_count')}',
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getText('page_subtitle'),
            style: const TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Enhanced Search Input
          Container(
            decoration: BoxDecoration(
              color: bgCanvas,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderLight),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: textMain, fontSize: 14),
              decoration: InputDecoration(
                hintText: _getText('search_hint'),
                hintStyle: TextStyle(
                  color: textMuted.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: textMuted,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 3),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: statusDangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: statusDangerFg,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getText('error_title'),
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchDashboardStats,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(_getText('try_again')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: borderLight.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searchQuery.isEmpty
                        ? Icons.people_outline_rounded
                        : Icons.search_off_rounded,
                    size: 44,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? _getText('empty_no_farmers')
                      : _getText('empty_no_results'),
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isEmpty
                      ? _getText('empty_no_farmers_subtitle')
                      : '${_getText('empty_no_results_prefix')}$_searchQuery${_getText('empty_no_results_suffix')}',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final hasRequests = _connectionRequests.isNotEmpty;
    final extraItems = hasRequests ? _connectionRequests.length + 1 : 0;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: farmers.length + extraItems,
      itemBuilder: (context, index) {
        if (hasRequests) {
          if (index == 0) {
            return _buildConnectionRequestsCard();
          }
          if (index <= _connectionRequests.length) {
            return _buildConnectionRequestRow(_connectionRequests[index - 1]);
          }
          return _buildFarmerCard(
            farmers[index - 1 - _connectionRequests.length],
          );
        }
        return _buildFarmerCard(farmers[index]);
      },
    );
  }

  /// Card that groups the pending farmer connection requests.
  Widget _buildConnectionRequestsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: statusWarningFg,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getText('requests_title'),
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: primaryGreen,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_connectionRequests.isEmpty)
              Text(
                _getText('requests_empty'),
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  /// A single pending connection request with Accept / Reject actions.
  Widget _buildConnectionRequestRow(VetConnectionRequest request) {
    final isResponding = _respondingConnectionIds.contains(
      request.connectionId,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusWarningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: darkGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.farmerName,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (request.farmerPhone.isNotEmpty)
                    Text(
                      request.farmerPhone,
                      style: const TextStyle(color: textMuted, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isResponding)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryGreen,
                ),
              )
            else ...[
              OutlinedButton(
                onPressed: () =>
                    _respondToConnection(request.connectionId, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusDangerFg,
                  side: const BorderSide(color: statusDangerFg),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _getText('reject'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () =>
                    _respondToConnection(request.connectionId, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _getText('accept'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
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
        statusFg = statusDangerFg;
        statusBg = statusDangerBg;
        break;
      case 'due_soon':
        statusFg = statusWarningFg;
        statusBg = statusWarningBg;
        break;
      case 'healthy':
      default:
        statusFg = statusSuccessFg;
        statusBg = statusSuccessBg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
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
                        color: bgCanvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderLight),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: darkGreen,
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
                              color: textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            farmer.farmName,
                            style: const TextStyle(
                              color: textMuted,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusFg,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _farmerStatusText(farmer),
                            style: TextStyle(
                              color: statusFg,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: borderLight),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          farmer.location,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.pets_rounded,
                          color: primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${farmer.flockCount} ${_getText('unit_flocks')} · ${farmer.totalBirds} ${_getText('unit_birds')}',
                          style: const TextStyle(
                            color: textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: surfaceWhite,
        border: Border(top: BorderSide(color: borderLight, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                isSelected: false,
                onTap: () =>
                    context.go('/vet-dashboard?lang=${widget.languageCode}'),
              ),
              _buildNavItem(
                icon: Icons.assignment_rounded,
                isSelected: false,
                onTap: () =>
                    context.go('/vet-reports?lang=${widget.languageCode}'),
              ),
              _buildNavItem(
                icon: Icons.people_alt_rounded,
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                isSelected: false,
                onTap: () => context.go('/vet-profile/${widget.languageCode}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: isSelected ? primaryGreen : textMuted),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
