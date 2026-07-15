import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/role.dart';

void main() {
  runApp(const VacTrackerApp());
}

class VacTrackerApp extends StatelessWidget {
  const VacTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VacTracker',
      theme: ThemeData(
        fontFamily:
            'Sans-Serif', // Replace with your specific font family if needed
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the color palette from the design
    const Color primaryGreen = Color(0xFF0D6E28); // Rich background green
    const Color buttonGreen = Color(
      0xFF6EBA7C,
    ); // Soft accent green for the button
    const Color textGreen = Color(0xFF0D6E28); // Text color inside the button

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Section: Logo, Title, and Subtitle
              Column(
                children: [
                  const SizedBox(height: 40),
                  // App Icon / Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .vaccines, // Replace with your custom SVG/Asset if needed
                      color: primaryGreen,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App Title
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
                  // Subtitle
                  Text(
                    'Protecting Poultry, Protecting\nFarmers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              // Middle Section: The Poultry Image with unique rounded corners
              Expanded(
                child: Center(
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    // Locate the middle section Container inside your WelcomePage widget and update the decoration:
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      image: const DecorationImage(
                        // Highlight-start: Changed from NetworkImage to AssetImage
                        image: AssetImage('assets/welcome/welcome pic.png'),
                        // Highlight-end
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Section: Get Started Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // This is the trigger that pushes the user to the role selection page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionPage(),
                        ),
                      );
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
