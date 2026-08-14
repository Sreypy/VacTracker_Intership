import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginOtpScreen extends StatefulWidget {
  final String phone;
  final String languageCode;
  final String? otpCode;

  const LoginOtpScreen({
    super.key,
    required this.phone,
    required this.languageCode,
    this.otpCode,
  });

  static Future<void> showOtpDialog({
    required BuildContext context,
    required String phone,
    required String languageCode,
    String? otpCode,
    required Future<void> Function(String otp) onVerify,
    required Future<void> Function() onResend,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return OtpVerificationDialog(
          phone: phone,
          languageCode: languageCode,
          otpCode: otpCode,
          onVerify: onVerify,
          onResend: onResend,
        );
      },
    );
  }

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final otpController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Verify OTP',
      'message': 'Enter the 6-digit code sent to your phone',
      'label': 'OTP Code',
      'verify': 'Verify',
      'resend': 'Resend OTP',
      'close': 'Close',
      'error_empty': 'Please enter the OTP',
      'error_invalid': 'Please enter a valid 6-digit code',
      'failed': 'Verification failed',
      'otp_from_server': 'Server OTP',
    },
    'km': {
      'title': 'បញ្ជាក់លេខកូដ OTP',
      'message': 'បញ្ចូលលេខកូដ 6 ខ្ទង់ដែលបានផ្ញើទៅទូរស័ព្ទរបស់អ្នក',
      'label': 'លេខកូដ OTP',
      'verify': 'បញ្ជាក់',
      'resend': 'ផ្ញើ OTP ម្តងទៀត',
      'close': 'បិទ',
      'error_empty': 'សូមបញ្ចូលលេខកូដ OTP',
      'error_invalid': 'សូមបញ្ចូលលេខកូដ 6 ខ្ទង់ដែលត្រឹមត្រូវ',
      'failed': 'ការបញ្ជាក់មិនបានសម្រេច',
      'otp_from_server': 'លេខកូដពីម៉ាស៊ីន',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('error_empty')),
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

      debugPrint('OTP verify result: $result');

      await StorageService.saveToken(result["access_token"]);
      await StorageService.saveUser(result["user"]);

      if (!mounted) return;

      final user = result["user"];

      if (user == null) {
        throw Exception("User data not found");
      }

      final role = user["role"];

      if (role == "farmer") {
        context.go("/farmer-dashboard?lang=${widget.languageCode}");
      } else if (role == "veterinarian") {
        context.go("/vet-dashboard?lang=${widget.languageCode}");
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unknown user role")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_getText('failed')}: $e"),
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          _getText('title'),
          style: const TextStyle(
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
                Text(
                  _getText('title'),
                  style: const TextStyle(
                    color: brandDarkGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_getText('message')}\n${widget.phone}',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'OTP Code',
                    style: TextStyle(
                      color: textDarkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: textDarkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.0,
                  ),
                  textAlign: TextAlign.center,
                  enabled: !loading,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(
                      color: textGrey.withValues(alpha: 0.3),
                      fontSize: 20,
                      letterSpacing: 8.0,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        Icons.lock_person_outlined,
                        color: textGrey.withValues(alpha: 0.7),
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
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : verifyOtp,
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
                            _getText('verify'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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

class OtpVerificationDialog extends StatefulWidget {
  final String phone;
  final String languageCode;
  final String? otpCode;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;

  const OtpVerificationDialog({
    super.key,
    required this.phone,
    required this.languageCode,
    this.otpCode,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  static const Color brandDarkGreen = Color(0xFF034418);
  static const Color brandHeaderGreen = Color(0xFF0D6E28);
  static const Color textDarkBlue = Color(0xFF0A1C33);
  static const Color textGrey = Color(0xFF5A6B82);
  static const Color errorRed = Color(0xFFB3261E);

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _errorText;

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Verify OTP',
      'message': 'Enter the 6-digit code sent to your phone',
      'verify': 'Verify',
      'resend': 'Resend OTP',
      'close': 'Close',
      'error_empty': 'Please enter the OTP',
      'error_invalid': 'Please enter a valid 6-digit code',
      'server_otp': 'Server OTP',
      'failed': 'Verification failed',
    },
    'km': {
      'title': 'បញ្ជាក់លេខកូដ OTP',
      'message': 'បញ្ចូលលេខកូដ 6 ខ្ទង់ដែលបានផ្ញើទៅទូរស័ព្ទរបស់អ្នក',
      'verify': 'បញ្ជាក់',
      'resend': 'ផ្ញើ OTP ម្តងទៀត',
      'close': 'បិទ',
      'error_empty': 'សូមបញ្ចូលលេខកូដ OTP',
      'error_invalid': 'សូមបញ្ចូលលេខកូដ 6 ខ្ទង់ដែលត្រឹមត្រូវ',
      'server_otp': 'លេខកូដពីម៉ាស៊ីន',
      'failed': 'ការបញ្ជាក់មិនបានសម្រេច',
    },
  };

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String get _otpValue =>
      _otpControllers.map((controller) => controller.text).join();

  void _updateOtpField(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) {
        _otpControllers[index].clear();
        return;
      }
      final chars = digits.split('');
      for (int i = 0; i < 6; i++) {
        if (i < chars.length) {
          _otpControllers[i].text = chars[i];
          _otpControllers[i].selection = TextSelection.collapsed(
            offset: _otpControllers[i].text.length,
          );
        } else {
          _otpControllers[i].clear();
        }
      }
      final nextIndex = chars.length >= 6 ? 5 : chars.length;
      FocusScope.of(context).requestFocus(_focusNodes[nextIndex]);
      return;
    }

    _otpControllers[index].text = value;
    _otpControllers[index].selection = TextSelection.collapsed(
      offset: _otpControllers[index].text.length,
    );

    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _handleVerify() async {
    final otp = _otpValue.trim();

    if (otp.length != 6) {
      setState(() {
        _errorText = _getText('error_invalid');
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await widget.onVerify(otp);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    try {
      setState(() {
        _loading = true;
        _errorText = null;
      });
      await widget.onResend();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('resend')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getText('title'),
                    style: const TextStyle(
                      color: brandDarkGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: textDarkBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getText('message'),
              style: const TextStyle(
                color: textGrey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if ((widget.otpCode ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: brandDarkGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Development OTP: ${widget.otpCode!.trim()}',
                  style: const TextStyle(
                    color: brandDarkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 42,
                  height: 52,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: const TextStyle(
                      color: textDarkBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    enabled: !_loading,
                    onChanged: (value) => _updateOtpField(index, value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: brandHeaderGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    color: errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _getText('verify'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: _loading ? null : _handleResend,
                style: TextButton.styleFrom(foregroundColor: brandDarkGreen),
                child: Text(
                  _getText('resend'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
