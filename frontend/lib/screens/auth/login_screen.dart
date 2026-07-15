import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();

  final authService = AuthService();

  void sendOtp() async {
    final result = await authService.sendOtp(phoneController.text);

    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: phoneController,

              decoration: const InputDecoration(labelText: "Phone Number"),
            ),

            ElevatedButton(onPressed: sendOtp, child: const Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
