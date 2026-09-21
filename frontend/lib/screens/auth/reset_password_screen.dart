import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String languageCode;

  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.languageCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = AuthService();
  bool loading = false;
  bool obscurePassword = true;

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Reset Password',
      'subtitle': 'Enter the code we sent you and choose a new password.',
      'label_otp': 'Verification Code',
      'hint_otp': '123456',
      'label_password': 'New Password',
      'hint_password': 'Enter new password',
      'label_confirm': 'Confirm Password',
      'hint_confirm': 'Re-enter new password',
      'btn_reset': 'Reset Password',
      'err_otp': 'Please enter the 6-digit code',
      'err_password': 'Password must be at least 6 characters',
      'err_mismatch': 'Passwords do not match',
      'err_failed': 'Failed: ',
      'success': 'Password reset. Please log in.',
    },
    'km': {
      'title': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
      'subtitle':
          'សូមបញ្ចូលលេខកូដដែលបានផ្ញើមកអ្នក ហើយជ្រើសរើសពាក្យសម្ងាត់ថ្មី។',
      'label_otp': 'លេខកូដផ្ទៀងផ្ទាត់',
      'hint_otp': '123456',
      'label_password': 'ពាក្យសម្ងាត់ថ្មី',
      'hint_password': 'បញ្ចូលពាក្យសម្ងាត់ថ្មី',
      'label_confirm': 'បញ្ជាក់ពាក្យសម្ងាត់',
      'hint_confirm': 'បញ្ចូលពាក្យសម្ងាត់ថ្មីម្តងទៀត',
      'btn_reset': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
      'err_otp': 'សូមបញ្ចូលលេខកូដ 6 ខ្ទង់',
      'err_password': 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច 6 តួអក្សរ',
      'err_mismatch': 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ',
      'err_failed': 'បរាជ័យ: ',
      'success': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញរួចរាល់។ សូមចូលប្រើប្រាស់។',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleReset() async {
    final otp = otpController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_otp')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_password')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('err_mismatch')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    try {
      setState(() => loading = true);

      await authService.resetPassword(widget.phone, otp, password);

      if (!mounted) return;

      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Text(_getText('success')),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Back to Login, clearing the forgot-password screens off the stack.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              LoginScreen(role: 'farmer', languageCode: widget.languageCode),
        ),
        (route) => false,
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: textGrey.withValues(alpha: 0.4),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: textGrey.withValues(alpha: 0.7)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
        borderSide: const BorderSide(color: brandHeaderGreen, width: 1.8),
      ),
    );
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
              const SizedBox(height: 32),

              Text(
                _getText('label_otp'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                enabled: !loading,
                maxLength: 6,
                style: const TextStyle(color: textDarkBlue, fontSize: 16),
                decoration: _fieldDecoration(
                  hint: _getText('hint_otp'),
                  icon: Icons.sms_outlined,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                _getText('label_password'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !loading,
                style: const TextStyle(color: textDarkBlue, fontSize: 16),
                decoration: _fieldDecoration(
                  hint: _getText('hint_password'),
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: textGrey.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                _getText('label_confirm'),
                style: const TextStyle(
                  color: textDarkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscurePassword,
                enabled: !loading,
                style: const TextStyle(color: textDarkBlue, fontSize: 16),
                decoration: _fieldDecoration(
                  hint: _getText('hint_confirm'),
                  icon: Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : handleReset,
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
                          _getText('btn_reset'),
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
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
