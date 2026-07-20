import 'package:flutter/material.dart';

class VetDashboardPage extends StatefulWidget {
  final String languageCode; // 'en' or 'km'
  final String? profileImageUrl; // Pass null or network URL string

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

  static const Color statusGreen = Color(0xFF0D6E28);
  // static const Color statusGreenBg = Color(0xFFE2F6EA);
  static const Color statusRed = Color(0xFFA80000);
  static const Color statusRedBg = Color(0xFFFDE8E8);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color compliantBg = Color(0xFFE2E8F0);
  static const Color compliantText = Color(0xFF5A6B82);

  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'welcome': 'Welcome back,',
      'dr_title': 'Dr. Sokha',
      'total_clients': 'Total Managed Clients',
      'overdue_label': 'OVERDUE',
      'due_today_label': 'DUE TODAY',
      'needs_action': '! Needs Action',
      'scheduled': 'Scheduled',
      'btn_reminders': 'Send Bulk Reminders',
      'directory_title': 'Client Directory',
      'sorting': 'Sorted by Priority',
      'compliant_label': 'COMPLIANT',
    },
    'km': {
      'welcome': 'ស្វាគមន៍ការត្រឡប់មកវិញ',
      'dr_title': 'វេជ្ជបណ្ឌិត សុខា',
      'total_clients': 'អតិថិជនគ្រប់គ្រងសរុប',
      'overdue_label': 'ហួសកំណត់',
      'due_today_label': 'ដល់កំណត់ថ្ងៃនេះ',
      'needs_action': '! ត្រូវការការពិនិត្យ',
      'scheduled': 'បានគ្រោងទុក',
      'btn_reminders': 'ផ្ញើការរំលឹកជាក្រុម',
      'directory_title': 'បញ្ជីឈ្មោះអតិថិជន',
      'sorting': 'តម្រៀបតាមអាទិភាព',
      'compliant_label': 'ត្រឹមត្រូវតាមស្តង់ដារ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  // Dynamic Avatar Loader Helper
  Widget _buildUserAvatar(String? avatarUrl, String displayName) {
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: hasAvatar
          ? Colors.transparent
          // ignore: deprecated_member_use, deprecated_member_uses
          : brandHeaderGreen.withOpacity(0.15),
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: hasAvatar
          ? null
          : Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
              style: const TextStyle(
                color: brandDarkGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: textGreyLight, height: 1),
        ),
        title: Row(
          children: [
            _buildUserAvatar(
              widget.profileImageUrl,
              "Sokha",
            ), // Profile Image Dynamic Avatar
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
              Icons.language_outlined,
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
              Text(
                _getText('welcome'),
                style: const TextStyle(color: textGrey, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                _getText('dr_title'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Total Managed Clients Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: brandDarkGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('total_clients'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "124",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Split Priority Metric Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusRedBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText('overdue_label'),
                            style: const TextStyle(
                              color: statusRed,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "12",
                            style: TextStyle(
                              color: statusRed,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getText('needs_action'),
                            style: const TextStyle(
                              color: statusRed,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: textGreyLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText('due_today_label'),
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "08",
                            style: TextStyle(
                              color: textDarkBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: brandHeaderGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getText('scheduled'),
                                style: const TextStyle(
                                  color: brandHeaderGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 20),

              // Send Reminders Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                  label: Text(
                    _getText('btn_reminders'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDarkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Directory Titles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getText('directory_title'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getText('sorting'),
                    style: const TextStyle(color: textGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Client Directory Cards
              _buildClientCard(
                title: "Battambang Poultry Co.",
                subtitle: "Ek Phnom, BTB",
                statusText: _getText('overdue_label'),
                iconData: Icons.agriculture_rounded,
                accentColor: statusRed,
                statusColor: Colors.white,
                statusBgColor: statusRed,
                iconBgColor: const Color(0xFFFDE8E8),
                iconColor: const Color(0xFFE11D48),
              ),
              const SizedBox(height: 12),
              _buildClientCard(
                title: "Sokha Phon",
                subtitle: "Kampong Speu",
                statusText: _getText('overdue_label'),
                iconData: Icons.person_rounded,
                accentColor: statusRed,
                statusColor: Colors.white,
                statusBgColor: statusRed,
                iconBgColor: const Color(0xFFFDE8E8),
                iconColor: const Color(0xFFE11D48),
              ),
              const SizedBox(height: 12),
              _buildClientCard(
                title: "Kandal Egg Farm",
                subtitle: "Sa'ang, Kandal",
                statusText: _getText('due_today_label'),
                iconData: Icons.egg_outlined,
                accentColor: statusGreen,
                statusColor: Colors.white,
                statusBgColor: statusGreen,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: statusGreen,
              ),
              const SizedBox(height: 12),
              _buildClientCard(
                title: "Prey Veng Cooperative",
                subtitle: "Prey Veng City",
                statusText: _getText('compliant_label'),
                iconData: Icons.home_work_outlined,
                accentColor: textGrey,
                statusColor: compliantText,
                statusBgColor: compliantBg,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: textGrey,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildClientCard({
    required String title,
    required String subtitle,
    required String statusText,
    required IconData iconData,
    required Color accentColor,
    required Color statusColor,
    required Color statusBgColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textGreyLight, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textDarkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: textGrey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(color: textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: textGrey,
                    size: 14,
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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: textGreyLight, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandDarkGreen,
        unselectedItemColor: textGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: brandDarkGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : const Icon(Icons.grid_view_rounded, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 24),
            label: '',
          ),
        ],
      ),
    );
  }
}
