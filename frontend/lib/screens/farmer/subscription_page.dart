import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  final String languageCode;

  const SubscriptionPage({super.key, required this.languageCode});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

enum PlanTier { basic, premium }

class _SubscriptionPageState extends State<SubscriptionPage> {
  late String _currentLang;

  // Display-only for now — no payment flow wired up yet.
  // Every new subscriber starts on a free first month regardless of
  // which tier they pick; after that they're billed at the tier price.
  PlanTier _currentPlan = PlanTier.basic;

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
      'trial_banner': 'Your first month is free on any plan.',
      'plan_basic_name': 'Basic',
      'plan_basic_price': '\$1.99/month',
      'plan_basic_trial_note': 'First month free',
      'plan_premium_name': 'Premium',
      'plan_premium_price': '\$4.99/month',
      'plan_premium_trial_note': 'First month free',
      'plan_current_badge': 'Current Plan',
      'plan_basic_feature_1': 'Flock tracking',
      'plan_basic_feature_2': 'Vaccination reminders',
      'plan_basic_feature_3': 'Vet Response (limited)',
      'plan_premium_feature_1': 'Everything in Basic',
      'plan_premium_feature_2': 'Unlimited vet connections',
      'plan_premium_feature_3': 'Priority vet response',
      'plan_premium_feature_4': 'Vaccine library access',
      'plan_premium_feature_5': 'In-app reminders',
      'btn_choose_basic': 'Switch to Basic',
      'btn_upgrade': 'Upgrade to Premium',
      'lbl_current_plan_basic': "You're on the Basic plan",
      'lbl_current_plan_premium': "You're on the Premium plan",
    },
    'km': {
      'title': 'គម្រោងសមាជិកភាព',
      'subtitle': 'ជ្រើសរើសគម្រោងដែលសមស្របនឹងកសិដ្ឋានរបស់អ្នក។',
      'trial_banner': 'ខែដំបូងឥតគិតថ្លៃលើគម្រោងណាមួយ។',
      'plan_basic_name': 'មូលដ្ឋាន',
      'plan_basic_price': '\$1.99/ខែ',
      'plan_basic_trial_note': 'ខែដំបូងឥតគិតថ្លៃ',
      'plan_premium_name': 'Premium',
      'plan_premium_price': '\$4.99/ខែ',
      'plan_premium_trial_note': 'ខែដំបូងឥតគិតថ្លៃ',
      'plan_current_badge': 'គម្រោងបច្ចុប្បន្ន',
      'plan_basic_feature_1': 'តាមដានហ្វូង',
      'plan_basic_feature_2': 'ការរំលឹកការចាក់វ៉ាក់សាំង',
      'plan_basic_feature_3': 'ជជែកជាមួយវេជ្ជបណ្ឌិត (មានកំណត់)',
      'plan_premium_feature_1': 'អ្វីៗទាំងអស់ក្នុងគម្រោងមូលដ្ឋាន',
      'plan_premium_feature_2': 'ការភ្ជាប់វេជ្ជបណ្ឌិតសត្វគ្មានកំណត់',
      'plan_premium_feature_3': 'ការឆ្លើយតបពីវេជ្ជបណ្ឌិតជាអាទិភាព',
      'plan_premium_feature_4': 'ចូលប្រើបណ្ណាល័យវ៉ាក់សាំង',
      'plan_premium_feature_5': 'ការរំលឹកតាម SMS',
      'btn_choose_basic': 'ប្តូរទៅមូលដ្ឋាន',
      'btn_upgrade': 'ដំឡើងទៅ Premium',
      'lbl_current_plan_basic': 'អ្នកកំពុងប្រើគម្រោងមូលដ្ឋាន',
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

  String _currentPlanLabel() {
    switch (_currentPlan) {
      case PlanTier.basic:
        return _getText('lbl_current_plan_basic');
      case PlanTier.premium:
        return _getText('lbl_current_plan_premium');
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
                _currentPlanLabel(),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: dialogLightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.celebration_outlined,
                      color: brandDarkGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getText('trial_banner'),
                        style: const TextStyle(
                          color: brandDarkGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPlanCard(
                name: _getText('plan_basic_name'),
                price: _getText('plan_basic_price'),
                trialNote: _getText('plan_basic_trial_note'),
                features: [
                  _getText('plan_basic_feature_1'),
                  _getText('plan_basic_feature_2'),
                  _getText('plan_basic_feature_3'),
                ],
                isCurrent: _currentPlan == PlanTier.basic,
                isPremium: false,
                buttonLabel: _getText('btn_choose_basic'),
                onSelect: () => setState(() => _currentPlan = PlanTier.basic),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                name: _getText('plan_premium_name'),
                price: _getText('plan_premium_price'),
                trialNote: _getText('plan_premium_trial_note'),
                features: [
                  _getText('plan_premium_feature_1'),
                  _getText('plan_premium_feature_2'),
                  _getText('plan_premium_feature_3'),
                  _getText('plan_premium_feature_4'),
                  _getText('plan_premium_feature_5'),
                ],
                isCurrent: _currentPlan == PlanTier.premium,
                isPremium: true,
                buttonLabel: _getText('btn_upgrade'),
                onSelect: () => setState(() => _currentPlan = PlanTier.premium),
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
    required String buttonLabel,
    required VoidCallback onSelect,
    String? trialNote,
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
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: textDarkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
          if (trialNote != null) ...[
            const SizedBox(height: 2),
            Text(
              trialNote,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDarkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: onSelect,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textDarkBlue,
                        side: const BorderSide(color: textGreyLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
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
