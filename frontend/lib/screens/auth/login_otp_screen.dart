import 'package:flutter/material.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phone;

  const LoginOtpScreen({super.key, required this.phone});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final otpController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  // Premium UI Design Theme Constants
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter OTP"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final result = await authService.verifyOtp(widget.phone, otp);

      await StorageService.saveToken(result["access_token"]);
      await StorageService.saveUser(result["user"]);

      print(result);

      if (!mounted) return;

      // User routing routing logic
      if (result["user"] == null) {
        // New user
        context.go("/register/farmer/en");
      } else {
        // Existing user
        final role = result["user"]["role"];

        if (role == "farmer") {
          context.go("/farmer-dashboard");
        } else if (role == "vet") {
          context.go("/vet-dashboard");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification failed: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Check if there is a valid history stack before popping
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback redirection to prevent the GoError crash
              context.go('/');
            }
          },
        ),
        title: const Text(
          "Verify Security Key",
          style: TextStyle(
            color: textDarkBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Heading Section
                const Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    color: brandDarkGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We have transmitted a 6-digit secure authentication key via SMS text message directly to ${widget.phone}.",
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Premium Input Matrix Field Label
                const Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    "One-Time Password (OTP)",
                    style: TextStyle(
                      color: textDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Styled TextFormField Block
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: textDarkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing:
                        8.0, // Clean spatial code presentation styling
                  ),
                  textAlign: TextAlign.center,
                  enabled: !loading,
                  decoration: InputDecoration(
                    counterText: "", // Hides messy default counter labels
                    hintText: "••••••",
                    hintStyle: TextStyle(
                      color: textGrey.withOpacity(0.3),
                      fontSize: 20,
                      letterSpacing: 8.0,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        Icons.lock_person_outlined,
                        color: textGrey.withOpacity(0.7),
                        size: 22,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: brandHeaderGreen,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Design System Branding Section Card Decorator
                Container(
                  width: double.infinity,
                  height: 140,
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
                const SizedBox(height: 36),

                // Core Verification Action Button Submission Layout
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: brandDarkGreen.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Verify & Continue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
