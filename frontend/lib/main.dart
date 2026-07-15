import 'package:flutter/material.dart';
import 'package:frontend/screens/welcome_page.dart';

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

      home: const WelcomePage(),
    );
  }
}
