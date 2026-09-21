import 'package:flutter/material.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';

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
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool loading = false;
  bool obscurePassword = true;

  // Design Theme Constants
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  // Localization Map matching your setup
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'subtitle': 'Enter your phone number and password to log in.',
      'label_phone': 'Phone Number',
      'hint_phone': '85512345678',
      'label_password': 'Password',
      'hint_password': 'Enter your password',
      'btn_login': 'Log In',
      'forgot_password': 'Forgot Password?',
      'footer_text': "Don't have an account? ",
      'footer_link': 'Register',
      'err_phone': 'Please enter phone number',
      'err_password': 'Please enter password',
      'err_failed': 'Failed: ',
    },
    'km': {
      'subtitle':
          'សូមបញ្ចូលលេខទូរស័ព្ទ និងពាក្យសម្ងាត់របស់អ្នក ដើម្បីចូលប្រើប្រាស់។',
      'label_phone': 'លេខទូរស័ព្ទ',
      'hint_phone': '85512345678',
      'label_password': 'ពាក្យសម្ងាត់',
      'hint_password': 'បញ្ចូលពាក្យសម្ងាត់របស់អ្នក',
      'btn_login': 'ចូលប្រើប្រាស់',
      'forgot_password': 'ភ្លេចពាក្យសម្ងាត់?',
      'footer_text': 'មិនទាន់មានគណនីមែនទេ? ',
      'footer_link': 'ចុះឈ្មោះ',
      'err_phone': 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'err_password': 'សូមបញ្ចូលពាក្យសម្ងាត់',
      'err_failed': 'បរាជ័យ: ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  Future<void> handleLogin() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_phone')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_password')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final appRouter = GoRouter.of(context);

    try {
      setState(() {
        loading = true;
      });

      // NOTE: AuthService needs a `login(phone, password)` method that
      // hits your backend's password-login endpoint and returns a map
      // shaped like { "access_token": ..., "user": {...} } — same
      // shape your old verifyOtp() returned, so the rest of this
      // function lines up with what you already had.
      final loginResult = await authService.login(phone, password);
      debugPrint('Login result: $loginResult');

      if (!mounted) return;

      await StorageService.saveToken(loginResult["access_token"]);
      await StorageService.saveUser(loginResult["user"]);

      final user = loginResult["user"];
      if (user == null) {
        throw Exception("User data not found");
      }

      final role = user["role"];

      if (role == "farmer") {
        if (!mounted) return;
        appRouter.go("/farmer-dashboard?lang=${widget.languageCode}");
      } else if (role == "veterinarian") {
        if (!mounted) return;
        appRouter.go("/vet-dashboard?lang=${widget.languageCode}");
      } else {
        throw Exception("Unknown user role");
      }
    } catch (e) {
      scaffoldMessenger?.showSnackBar(
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
                          color: Colors.black.withValues(alpha: 0.05),
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

                // Phone Field
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
                      color: textGrey.withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: textGrey.withValues(alpha: 0.7),
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
                const SizedBox(height: 20),

                // Password Field
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    _getText('label_password'),
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: textDarkBlue, fontSize: 16),
                  enabled: !loading,
                  onSubmitted: (_) => loading ? null : handleLogin(),
                  decoration: InputDecoration(
                    hintText: _getText('hint_password'),
                    hintStyle: TextStyle(
                      color: textGrey.withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: textGrey.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: textGrey.withValues(alpha: 0.7),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
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

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      if (!loading) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordScreen(
                              languageCode: widget.languageCode,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      _getText('forgot_password'),
                      style: const TextStyle(
                        color: brandHeaderGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Login Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: brandDarkGreen.withValues(
                        alpha: 0.6,
                      ),
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
                                _getText('btn_login'),
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
    passwordController.dispose();
    super.dispose();
  }
}
