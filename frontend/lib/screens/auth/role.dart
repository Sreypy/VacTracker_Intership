import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  // Track the selected role: 'farmer', 'veterinarian', or null
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    // Styling Colors matching UI Design
    const Color backgroundLight = Color(0xFFF7F9FC);
    const Color brandGreen = Color(0xFF0D6E28);
    const Color textDarkBlue = Color(0xFF0A1C33);
    const Color textGrey = Color(0xFF5A6B82);
    const Color activeBorderColor = Color(0xFF0D6E28);
    const Color inactiveButtonColor = Color(
      0xFF9E9E9E,
    ); // Disabled look from screenshot

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar / App Logo + Title
              Row(
                children: [
                  const Icon(
                    Icons.vaccines, // Replace with your custom SVG icon
                    color: brandGreen,
                    size: 28,
                  ),
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
              const SizedBox(height: 36),

              // 2. Heading Texts
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  color: textDarkBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your account type to access your personalized dashboard.',
                style: TextStyle(color: textGrey, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 24),

              // 3. Farmer Role Selection Card
              _buildRoleCard(
                id: 'farmer',
                title: 'Farmer',
                description: 'Manage your flocks and track vaccinations.',
                iconData:
                    Icons.agriculture, // Using material icon approximation
                iconBgColor: const Color(0xFF1E7E34),
                isSelected: _selectedRole == 'farmer',
                onTap: () {
                  setState(() => _selectedRole = 'farmer');
                },
              ),
              const SizedBox(height: 16),

              // 4. Veterinarian Role Selection Card
              _buildRoleCard(
                id: 'veterinarian',
                title: 'Veterinarian',
                description: 'Monitor farm health and manage client flocks.',
                iconData: Icons.medical_services_outlined,
                iconBgColor: const Color(0xFF76D787),
                isSelected: _selectedRole == 'veterinarian',
                onTap: () {
                  setState(() => _selectedRole = 'veterinarian');
                },
              ),
              const SizedBox(height: 24),

              // 5. Illustration Asset Image
              Container(
                width: double.infinity,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(
                    // Note: Update pubspec.yaml and name your uploaded asset accordingly
                    image: AssetImage('assets/welcome/role pic.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Action Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedRole != null
                        ? () {
                            // Navigate forward based on _selectedRole value
                          }
                        : null, // Disabled when no selection is made
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      disabledBackgroundColor: inactiveButtonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Support Footer Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Need help? ',
                    style: const TextStyle(color: textDarkBlue, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Contact Support',
                        style: const TextStyle(
                          color: brandGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle context support action
                          },
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

  // Reusable Role Card Component Builder
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
            // Icon Square Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            // Card Texts
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
