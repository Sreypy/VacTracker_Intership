import 'package:flutter/material.dart';
import 'reset_password_screen.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String languageCode;

  const ForgotPasswordScreen({super.key, required this.languageCode});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Forgot Password',
      'subtitle':
          'Enter your phone number and we will send you a verification code.',
      'label_phone': 'Phone Number',
      'hint_phone': '85512345678',
      'btn_send': 'Send Code',
      'err_phone': 'Please enter phone number',
      'err_failed': 'Failed: ',
    },
    'km': {
      'title': 'ភ្លេចពាក្យសម្ងាត់',
      'subtitle':
          'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក យើងនឹងផ្ញើលេខកូដផ្ទៀងផ្ទាត់ជូនអ្នក។',
      'label_phone': 'លេខទូរស័ព្ទ',
      'hint_phone': '85512345678',
      'btn_send': 'ផ្ញើលេខកូដ',
      'err_phone': 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'err_failed': 'បរាជ័យ: ',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  Future<void> sendCode() async {
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

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    try {
      setState(() => loading = true);

      final result = await authService.sendOtp(phone);
      debugPrint('OTP send result: $result');

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            phone: phone,
            languageCode: widget.languageCode,
          ),
        ),
      );
    } catch (e) {
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Text("${_getText('err_failed')}$e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
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
        iconTheme: const IconThemeData(color: textDarkBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('title'),
                style: const TextStyle(
                  color: brandDarkGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
                enabled: !loading,
                style: const TextStyle(color: textDarkBlue, fontSize: 16),
                decoration: InputDecoration(
                  hintText: _getText('hint_phone'),
                  hintStyle: TextStyle(
                    color: textGrey.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: textGrey.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : sendCode,
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
                      : Text(
                          _getText('btn_send'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
