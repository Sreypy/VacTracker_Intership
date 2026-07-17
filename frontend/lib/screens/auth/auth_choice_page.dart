import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthChoicePage extends StatelessWidget {
  final String role;
  final String languageCode;

  const AuthChoicePage({
    super.key,
    required this.role,
    required this.languageCode,
  });

  // Premium UI Design Theme Constants
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  // Localization Map for Page Custom Headers
  final Map<String, Map<String, String>> _localizedValues = const {
    'en': {
      'farmer_title': 'Farmer Portal',
      'vet_title': 'Veterinarian Portal',
      'subtitle':
          'Select your entry pathway to access localized diagnostic logs and tracking assets.',
      'btn_login': 'Log In to Account',
      'btn_register': 'Create New Profile',
    },
    'km': {
      'farmer_title': 'ប្រព័ន្ធសម្រាប់កសិករ',
      'vet_title': 'ប្រព័ន្ធសម្រាប់បសុពេទ្យ',
      'subtitle':
          'សូមជ្រើសរើសជម្រើសខាងក្រោម ដើម្បីចូលទៅកាន់ប្រព័ន្ធតាមដាន និងកំណត់ត្រាជំងឺសត្វ។',
      'btn_login': 'ចូលគណនីរបស់អ្នក',
      'btn_register': 'បង្កើតគណនីថ្មី',
    },
  };

  String _getText(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final isFarmer = role == "farmer";
    final appBarTitleKey = isFarmer ? 'farmer_title' : 'vet_title';

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textDarkBlue,
            size: 22,
          ),
          onPressed: () {
            // Safe pop validation preventing the GoError crash
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Safe fallback to your initial entry point
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Clean Vector Profile Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: brandHeaderGreen.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFarmer
                          ? Icons.agriculture_rounded
                          : Icons.medical_services_outlined,
                      color: brandHeaderGreen,
                      size: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Heading Section
                Text(
                  _getText(appBarTitleKey),
                  style: const TextStyle(
                    color: brandDarkGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getText('subtitle'),
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // 1. Primary Elevated Login Action Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/login/$role/$languageCode');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getText('btn_login'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.login_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Secondary Stylized Outline Registration Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isFarmer) {
                        context.push('/register/farmer/$languageCode');
                      } else {
                        context.push('/register/vet/$languageCode');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: brandHeaderGreen,
                      side: const BorderSide(
                        color: brandHeaderGreen,
                        width: 1.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getText('btn_register'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.person_add_alt_1_outlined, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Brand Identity Graphical Banner
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: AssetImage('assets/welcome/Banner Section.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
