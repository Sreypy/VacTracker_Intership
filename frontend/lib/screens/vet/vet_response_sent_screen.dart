import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetResponseSentScreen extends StatefulWidget {
  final String reportId;
  final String languageCode;

  const VetResponseSentScreen({
    super.key,
    required this.reportId,
    this.languageCode = 'en',
  });

  @override
  State<VetResponseSentScreen> createState() => _VetResponseSentScreenState();
}

class _VetResponseSentScreenState extends State<VetResponseSentScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenBg = Color(0xFFD1FAE5);

  // Localization
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Response Sent',
      'subtitle': 'Your advice has been sent to',
      'status_vet_responded': 'Responded',
      'label_diagnosis': 'Diagnosis',
      'label_advice': 'Advice',
      'label_followup': 'Follow-up',
      'btn_back': 'Back to Sick Reports',
    },
    'km': {
      'title': 'ការឆ្លើយតបត្រូវបានផ្ញើ',
      'subtitle': 'ដំបូន្មានរបស់អ្នកត្រូវបានផ្ញើទៅកាន់',
      'status_vet_responded': 'បានឆ្លើយតប',
      'label_diagnosis': 'ការធ្វើរោគវិនិច្ឆ័យ',
      'label_advice': 'ដំបូន្មាន',
      'label_followup': 'តាមដានបន្ទាប់',
      'btn_back': 'ត្រឡប់ទៅរបាយការណ៍សត្វឈឺ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final extra =
        (GoRouterState.of(context).extra ?? <String, dynamic>{})
            as Map<String, dynamic>;
    final farmerName = extra['farmerName']?.toString() ?? 'the farmer';
    final diagnosis = extra['diagnosis']?.toString() ?? '';
    final advice = extra['advice']?.toString() ?? '';
    final followUpDate = extra['followUpDate'] as DateTime?;

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _getText('title'),
          style: const TextStyle(
            color: primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: successGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: successGreen,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Center(
                child: Text(
                  _getText('title'),
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  '${_getText('subtitle')} $farmerName.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textMuted, fontSize: 15),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: successGreenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: successGreen,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getText('status_vet_responded'),
                        style: const TextStyle(
                          color: successGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Diagnosis Card
              _buildSummaryCard(
                icon: Icons.medical_information_outlined,
                label: _getText('label_diagnosis'),
                value: diagnosis,
              ),
              const SizedBox(height: 12),

              // Advice Card
              _buildSummaryCard(
                icon: Icons.lightbulb_outline_rounded,
                label: _getText('label_advice'),
                value: advice,
              ),
              const SizedBox(height: 12),

              // Follow-up Card
              _buildSummaryCard(
                icon: Icons.calendar_today_outlined,
                label: _getText('label_followup'),
                value: _formatDate(followUpDate),
              ),
              const SizedBox(height: 32),

              // Back Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/vet-reports?lang=${widget.languageCode}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getText('btn_back'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFCBD5E1), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
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

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryGreen),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
