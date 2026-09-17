import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter instead of other pages

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF0D6E28);
    const Color buttonGreen = Color(0xFF6EBA7C);
    const Color textGreen = Color(0xFF0D6E28);

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vaccines,
                      color: primaryGreen,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'VacTracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Protecting Poultry, Protecting\nFarmers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: const DecorationImage(
                        image: AssetImage('assets/welcome/welcome pic.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate using path routing
                      context.push('/language');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGreen,
                      foregroundColor: textGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Get Start',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
