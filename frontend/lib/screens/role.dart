import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatefulWidget {
  final String languageCode;

  const RoleSelectionPage({super.key, required this.languageCode});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Choose Your Role',
      'subtitle':
          'Select your account type to access your personalized dashboard.',
      'farmer_title': 'Farmer',
      'farmer_desc': 'Manage your flocks and track vaccinations.',
      'vet_title': 'Veterinarian',
      'vet_desc': 'Monitor farm health and manage client flocks.',
      'continue': 'Continue',
      'help': 'Need help? ',
      'support': 'Contact Support',
    },
    'km': {
      'title': 'ជ្រើសរើសតួនាទីរបស់អ្នក',
      'subtitle':
          'ជ្រើសរើសប្រភេទគណនីរបស់អ្នក ដើម្បីចូលទៅកាន់ផ្ទាំងគ្រប់គ្រងផ្ទាល់ខ្លួន។',
      'farmer_title': 'កសិករ',
      'farmer_desc': 'គ្រប់គ្រងហ្វូងបក្សីរបស់អ្នក និងតាមដានការចាក់វ៉ាក់សាំង។',
      'vet_title': 'បសុពេទ្យ',
      'vet_desc': 'តាមដានសុខភាពកសិដ្ឋាន និងគ្រប់គ្រងហ្វូងបក្សីរបស់អតិថិជន។',
      'continue': 'បន្តទៅមុខទៀត',
      'help': 'ត្រូវការជំនួយទេ? ',
      'support': 'ទាក់ទងផ្នែកគាំទ្រ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

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
        child: SingleChildScrollView(
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
                    onPressed: () => context.pop(),
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
              const SizedBox(height: 24),
              Text(
                _getText('title'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getText('subtitle'),
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _buildRoleCard(
                id: 'farmer',
                title: _getText('farmer_title'),
                description: _getText('farmer_desc'),
                iconData: Icons.agriculture,
                iconBgColor: const Color(0xFF1E7E34),
                isSelected: _selectedRole == 'farmer',
                onTap: () => setState(() => _selectedRole = 'farmer'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                id: 'veterinarian',
                title: _getText('vet_title'),
                description: _getText('vet_desc'),
                iconData: Icons.medical_services_outlined,
                iconBgColor: const Color(0xFF6EBA7C),
                isSelected: _selectedRole == 'veterinarian',
                onTap: () => setState(() => _selectedRole = 'veterinarian'),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(
                    image: AssetImage('assets/welcome/role pic.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedRole != null
                        ? () {
                            if (_selectedRole == 'farmer') {
                              context.push(
                                '/auth-choice/farmer/${widget.languageCode}',
                              );
                            } else if (_selectedRole == 'veterinarian') {
                              context.push(
                                '/auth-choice/veterinarian/${widget.languageCode}',
                              );
                            }
                            // Hand over configuration to dashboard deep linking paths later: context.push('/register/${widget.languageCode}/$_selectedRole');
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
                          _getText('continue'),
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
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: _getText('help'),
                    style: const TextStyle(color: textDarkBlue, fontSize: 14),
                    children: [
                      TextSpan(
                        text: _getText('support'),
                        style: const TextStyle(
                          color: brandGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String id,
    required String title,
    required String description,
    required IconData iconData,
    required Color iconBgColor,
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5A6B82),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
