import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  final String languageCode;

  const SubscriptionPage({super.key, required this.languageCode});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late String _currentLang;

  // Display-only for now — no payment flow wired up yet.
  bool _isPremium = false;

  // Design System Colors (matching FarmerProfilePage)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color textGreyLight = Color(0xFFE2E8F0);
  static const Color dialogLightGreen = Color(0xFFEAF5EE);

  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'title': 'Subscription',
      'subtitle': 'Choose the plan that fits your farm.',
      'plan_free_name': 'Free',
      'plan_free_price': '\$0/month',
      'plan_premium_name': 'Premium',
      'plan_premium_price': '\$4.99/month',
      'plan_current_badge': 'Current Plan',
      'plan_free_feature_1': 'Flock tracking',
      'plan_free_feature_2': 'Vaccination reminders',
      'plan_free_feature_3': 'Basic sick reporting',
      'plan_premium_feature_1': 'Everything in Free',
      'plan_premium_feature_2': 'Unlimited vet connections',
      'plan_premium_feature_3': 'Priority vet response',
      'plan_premium_feature_4': 'Vaccine library access',
      'plan_premium_feature_5': 'SMS reminders',
      'btn_upgrade': 'Upgrade to Premium',
      'btn_downgrade': 'Switch to Free',
      'lbl_current_plan_free': "You're on the Free plan",
      'lbl_current_plan_premium': "You're on the Premium plan",
    },
    'km': {
      'title': 'គម្រោងសមាជិកភាព',
      'subtitle': 'ជ្រើសរើសគម្រោងដែលសមស្របនឹងកសិដ្ឋានរបស់អ្នក។',
      'plan_free_name': 'ឥតគិតថ្លៃ',
      'plan_free_price': '\$0/ខែ',
      'plan_premium_name': 'Premium',
      'plan_premium_price': '\$4.99/ខែ',
      'plan_current_badge': 'គម្រោងបច្ចុប្បន្ន',
      'plan_free_feature_1': 'តាមដានហ្វូង',
      'plan_free_feature_2': 'ការរំលឹកការចាក់វ៉ាក់សាំង',
      'plan_free_feature_3': 'របាយការណ៍ជំងឺមូលដ្ឋាន',
      'plan_premium_feature_1': 'អ្វីៗទាំងអស់ក្នុងគម្រោងឥតគិតថ្លៃ',
      'plan_premium_feature_2': 'ការភ្ជាប់វេជ្ជបណ្ឌិតសត្វគ្មានកំណត់',
      'plan_premium_feature_3': 'ការឆ្លើយតបពីវេជ្ជបណ្ឌិតជាអាទិភាព',
      'plan_premium_feature_4': 'ចូលប្រើបណ្ណាល័យវ៉ាក់សាំង',
      'plan_premium_feature_5': 'ការរំលឹកតាម SMS',
      'btn_upgrade': 'ដំឡើងទៅ Premium',
      'btn_downgrade': 'ប្តូរទៅឥតគិតថ្លៃ',
      'lbl_current_plan_free': 'អ្នកកំពុងប្រើគម្រោងឥតគិតថ្លៃ',
      'lbl_current_plan_premium': 'អ្នកកំពុងប្រើគម្រោង Premium',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
  }

  String _getText(String key) {
    return _localizedValues[_currentLang]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textDarkBlue),
        title: Text(
          _getText('title'),
          style: const TextStyle(
            color: brandDarkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('subtitle'),
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isPremium
                    ? _getText('lbl_current_plan_premium')
                    : _getText('lbl_current_plan_free'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildPlanCard(
                name: _getText('plan_free_name'),
                price: _getText('plan_free_price'),
                features: [
                  _getText('plan_free_feature_1'),
                  _getText('plan_free_feature_2'),
                  _getText('plan_free_feature_3'),
                ],
                isCurrent: !_isPremium,
                isPremium: false,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                name: _getText('plan_premium_name'),
                price: _getText('plan_premium_price'),
                features: [
                  _getText('plan_premium_feature_1'),
                  _getText('plan_premium_feature_2'),
                  _getText('plan_premium_feature_3'),
                  _getText('plan_premium_feature_4'),
                  _getText('plan_premium_feature_5'),
                ],
                isCurrent: _isPremium,
                isPremium: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Subscription plan card. Display-only for now — the buttons are
  // placeholder hooks for wiring up a real upgrade/downgrade/payment
  // flow later.
  Widget _buildPlanCard({
    required String name,
    required String price,
    required List<String> features,
    required bool isCurrent,
    required bool isPremium,
  }) {
    final accentColor = isPremium ? brandDarkGreen : textGrey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCurrent ? dialogLightGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? brandDarkGreen : textGreyLight,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPremium)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              Text(
                name,
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: brandDarkGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getText('plan_current_badge'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              color: accentColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: textGrey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCurrent) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: isPremium
                  ? ElevatedButton(
                      onPressed: () => setState(() => _isPremium = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDarkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _getText('btn_upgrade'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => setState(() => _isPremium = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textDarkBlue,
                        side: const BorderSide(color: textGreyLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _getText('btn_downgrade'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
