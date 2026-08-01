import 'package:flutter/material.dart';

class VaccinationHistoryScreen extends StatefulWidget {
  final String flockId;
  final String flockDetails;
  final String languageCode; // 'en' or 'km'

  const VaccinationHistoryScreen({
    super.key,
    this.flockId = 'KH-882-B',
    this.flockDetails = '2,500 Broiler Chickens in Barn 4',
    this.languageCode = 'km', // Default to Khmer
  });

  @override
  State<VaccinationHistoryScreen> createState() =>
      _VaccinationHistoryScreenState();
}

class _VaccinationHistoryScreenState extends State<VaccinationHistoryScreen> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF034418);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  static const Color textDark = Color(0xFF0A1C33);
  static const Color textMuted = Color(0xFF64748B);

  static const Color badgeDoneBg = Color(0xFF1B5E20);
  static const Color badgeDoneText = Colors.white;

  static const Color badgeMissedBg = Color(0xFFFFEBEE);
  static const Color badgeMissedText = Color(0xFFC62828);

  static const Color calloutBg = Color(0xFFFFF5F5);
  static const Color calloutText = Color(0xFFC62828);

  // Localization Dictionary
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'VacTracker',
      'flock_label': 'Flock ID:',
      'history_title': 'Vaccination History',
      'history_subtitle': 'Complete record of health interventions for the',
      'completed': 'Completed',
      'next_due': 'Next Due',
      'recent_records': 'Recent Records',
      'filter': 'Filter',
      'download_pdf': 'Download PDF History',
      'done': 'Done',
      'missed': 'Missed',
    },
    'km': {
      'app_title': 'VacTracker',
      'flock_label': 'លេខសម្គាល់ហ្វូង:',
      'history_title': 'ប្រវត្តិការចាក់វ៉ាក់សាំង',
      'history_subtitle': 'កំណត់ត្រាពេញលេញនៃការថែទាំសុខភាពសម្រាប់',
      'completed': 'បានបញ្ចប់',
      'next_due': 'កំណត់បន្ទាប់',
      'recent_records': 'កំណត់ត្រាថ្មីៗ',
      'filter': 'តម្រង',
      'download_pdf': 'ទាញយកប្រវត្តិជា PDF',
      'done': 'រួចរាល់',
      'missed': 'ខកខាន',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  // Mocked History Data with Multilingual Support
  List<Map<String, dynamic>> _getRecords() {
    final isKhmer = widget.languageCode == 'km';

    return [
      {
        'title': isKhmer ? 'ជំងឺញូវកាសិន (ND)' : 'Newcastle Disease (ND)',
        'subtitle': isKhmer
            ? 'ដូសជំរុញ • បន្តក់ភ្នែក'
            : 'Booster Dose • Eye Drop',
        'status': _getText('done'),
        'date': isKhmer ? '១២ តុលា ២០២៣' : 'Oct 12, 2023',
        'administrator': isKhmer ? 'វេជ្ជបណ្ឌិត សុខា' : 'Dr. Sokha',
        'adminType': 'person',
        'isMissed': false,
      },
      {
        'title': isKhmer
            ? 'ជំងឺហ្គំបូរ៉ូ (IBD)'
            : 'Infectious Bursal Disease (IBD)',
        'subtitle': isKhmer ? 'ដូសដំបូង • តាមមាត់' : 'Primary Dose • Oral',
        'status': _getText('done'),
        'date': isKhmer ? '២៨ កញ្ញា ២០២៣' : 'Sep 28, 2023',
        'administrator': isKhmer ? 'វេជ្ជបណ្ឌិត សុខា' : 'Dr. Sokha',
        'adminType': 'person',
        'isMissed': false,
      },
      {
        'title': isKhmer ? 'វ៉ាក់សាំងអុតស្បែក' : 'Fowl Pox Vaccine',
        'subtitle': isKhmer ? 'ចាក់តាមស្លាប' : 'Wing Web Prick',
        'status': _getText('missed'),
        'date': isKhmer ? '១៤ កញ្ញា ២០២៣' : 'Sep 14, 2023',
        'administrator': null,
        'isMissed': true,
        'note': isKhmer
            ? 'បានពន្យារពេលដោយសារការសង្កេតឃើញហ្វូងមានភាពតានតឹង។'
            : 'Rescheduled due to flock stress observations.',
      },
      {
        'title': isKhmer ? 'ជំងឺម៉ារ៉ិក' : 'Marek\'s Disease',
        'subtitle': isKhmer
            ? 'អាយុ ១ ថ្ងៃ • ចាក់ក្រោមស្បែកនៅកសិដ្ឋាន'
            : 'Day Old • Hatchery Sub-Q',
        'status': _getText('done'),
        'date': isKhmer ? '៣០ សីហា ២០២៣' : 'Aug 30, 2023',
        'administrator': isKhmer ? 'កសិដ្ឋាន CP' : 'CP Hatchery',
        'adminType': 'facility',
        'isMissed': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final records = _getRecords();

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _getText('app_title'),
          style: const TextStyle(
            color: primaryGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                '${_getText('flock_label')} ${widget.flockId}',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getText('history_title'),
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_getText('history_subtitle')} ${widget.flockDetails}.',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Metrics Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.verified_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: primaryGreen,
                      label: _getText('completed'),
                      value: '12',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.medical_services_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: primaryGreen,
                      label: _getText('next_due'),
                      value: widget.languageCode == 'km' ? '២៤ តុលា' : 'Oct 24',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sub-header & Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getText('recent_records'),
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            size: 18,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getText('filter'),
                            style: const TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // History Timeline List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final isLast = index == records.length - 1;
                  return _buildTimelineItem(record, isLast);
                },
              ),
              const SizedBox(height: 24),

              // Download PDF Button
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: primaryGreen,
                ),
                label: Text(
                  _getText('download_pdf'),
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> record, bool isLast) {
    final bool isMissed = record['isMissed'] ?? false;
    final Color statusColor = isMissed ? badgeMissedText : primaryGreen;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isMissed ? badgeMissedText : primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMissed ? Icons.error_outline : Icons.vaccines,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: Colors.grey[300])),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: statusColor, width: 4),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                record['title'],
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isMissed ? badgeMissedBg : badgeDoneBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record['status'],
                                style: TextStyle(
                                  color: isMissed
                                      ? badgeMissedText
                                      : badgeDoneText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record['subtitle'],
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),

                        if (isMissed && record['note'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: calloutBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: calloutText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    record['note'],
                                    style: const TextStyle(
                                      color: calloutText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[200], height: 1),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              record['date'],
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (record['administrator'] != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                record['adminType'] == 'facility'
                                    ? Icons.domain_outlined
                                    : Icons.person_outline,
                                size: 16,
                                color: textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record['administrator'],
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey[500],
      currentIndex: 2,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.vaccines_outlined),
          label: 'Vaccines',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Records',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
