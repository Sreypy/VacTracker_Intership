import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    const Color backgroundLight = Color(0xFFF7F9FC);
    const Color brandGreen = Color(0xFF0D6E28);
    const Color textDarkBlue = Color(0xFF0A1C33);
    const Color textGrey = Color(0xFF5A6B82);
    const Color inactiveButtonColor = Color(0xFFB0B8C4);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: textDarkBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const Icon(Icons.vaccines, color: brandGreen, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'VacTracker',
                    style: TextStyle(
                      color: brandGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Select Language / ជ្រើសរើសភាសា',
                style: TextStyle(
                  color: textDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please choose your preferred language to continue.',
                style: TextStyle(color: textGrey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildLanguageCard(
                id: 'en',
                title: 'English',
                subtitle: 'Use the app in English',
                flagIcon: '🇺🇸',
                isSelected: _selectedLanguage == 'en',
                onTap: () => setState(() => _selectedLanguage = 'en'),
              ),
              const SizedBox(height: 16),
              // Inside language_page.dart widget tree:
              _buildLanguageCard(
                id: 'km', // Changed to match backend Language.KM
                title: 'ភាសាខ្មែរ',
                subtitle: 'ប្រើប្រាស់កម្មវិធីជាភាសាខ្មែរ',
                flagIcon: '🇰🇭',
                isSelected: _selectedLanguage == 'km',
                onTap: () => setState(() => _selectedLanguage = 'km'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedLanguage != null
                      ? () {
                          // Injecting parameter state down the GoRouter pipeline
                          context.push('/role/$_selectedLanguage');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    disabledBackgroundColor: inactiveButtonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedLanguage == 'km' ? 'បន្តទៅមុខទៀត' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
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

  Widget _buildLanguageCard({
    required String id,
    required String title,
    required String subtitle,
    required String flagIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D6E28) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flagIcon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0A1C33),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF5A6B82),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0D6E28),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
