import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final String languageCode;

  const LoginScreen({
    super.key,
    required this.role,
    required this.languageCode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  // Design Theme Constants
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  // Localization Map matching your setup
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'subtitle':
          'Enter your contact number to receive a secure login verification key.',
      'label_phone': 'Phone Number',
      'hint_phone': '85512345678',
      'btn_send': 'Send OTP',
      'footer_text': "Don't have an account? ",
      'footer_link': 'Register',
      'err_phone': 'Please enter phone number',
      'err_failed': 'Failed: ',
    },
    'km': {
      'subtitle':
          'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក ដើម្បីទទួលលេខកូដផ្ទៀងផ្ទាត់ចូលប្រព័ន្ធដែលមានសុវត្ថិភាព។',
      'label_phone': 'លេខទូរស័ព្ទ',
      'hint_phone': '85512345678',
      'btn_send': 'ផ្ញើលេខកូដ OTP',
      'footer_text': 'មិនទាន់មានគណនីមែនទេ? ',
      'footer_link': 'ចុះឈ្មោះ',
      'err_phone': 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'err_failed': 'បរាជ័យ: ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_phone')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final exists = await authService.checkPhone(phone);
      if (!mounted) return;
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.role == 'farmer'
                  ? 'Phone number not registered. Please register first.'
                  : 'Phone number not registered. Please register first.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final result = await authService.sendOtp(phone);
      print(result);

      if (!mounted) return;

      context.go(
        "/login-otp",
        extra: {'phone': phone, 'lang': widget.languageCode},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_getText('err_failed')}$e"),
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
                // Minimal Header Branding Row
                Center(
                  child: Text(
                    'VacTracker',
                    style: TextStyle(
                      color: brandHeaderGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Form Welcome Texts
                Text(
                  widget.languageCode == 'km' ? 'ស្វាគមន៍' : 'Welcome Back',
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
                const SizedBox(height: 36),

                // Premium Input Matrix Field
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    _getText('label_phone'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: textDarkBlue, fontSize: 16),
                  enabled: !loading,
                  decoration: InputDecoration(
                    hintText: _getText('hint_phone'),
                    hintStyle: TextStyle(
                      color: textGrey.withOpacity(0.4),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: textGrey.withOpacity(0.7),
                      size: 22,
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

                // Brand Graphic Banner Card Accent
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

                // Secure OTP Submission Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : sendOtp,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getText('btn_send'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // Navigation Link Footer Element
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getText('footer_text'),
                      style: const TextStyle(color: textGrey, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!loading) {
                          final registerPath = widget.role == 'farmer'
                              ? '/register/farmer/${widget.languageCode}'
                              : '/register/vet/${widget.languageCode}';
                          context.go(registerPath);
                        }
                      },
                      child: Text(
                        _getText('footer_link'),
                        style: const TextStyle(
                          color: brandHeaderGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
