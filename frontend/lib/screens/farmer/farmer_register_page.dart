import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class FarmerRegisterPage extends StatefulWidget {
  final String languageCode; // Router parameter passing down 'en' or 'kh'

  const FarmerRegisterPage({super.key, required this.languageCode});

  @override
  State<FarmerRegisterPage> createState() => _FarmerRegisterPageState();
}

class _FarmerRegisterPageState extends State<FarmerRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // TypeORM Entity Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _villageController = TextEditingController();
  final _provinceController = TextEditingController();
  final authService = AuthService();

  // Premium Context Translation Dictionary
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Create Farmer Account',
      'subtitle':
          'Join the network of dependable poultry guardians and protect your flock with expert veterinary precision.',
      'label_name': 'Full Name',
      'hint_name': 'Enter your full name',
      'label_phone': 'Phone Number',
      'hint_phone': '012 345 678',
      'label_password': 'Password',
      'hint_password': '••••••••',
      'label_village': 'Village',
      'hint_village': 'Enter your village name',
      'label_province': 'Province',
      'hint_province': 'Enter your province',
      'btn_submit': 'Complete Registration',
      'footer_text': 'Already have an account? ',
      'footer_link': 'Log In',
      'err_name': 'Please enter your full name',
      'err_phone': 'Please enter your phone number',
      'err_pass': 'Password must be at least 6 characters',
    },
    'km': {
      'title': 'បង្កើតគណនីកសិករ',
      'subtitle':
          'ចូលរួមជាមួយបណ្តាញអ្នកថែរក្សាបសុបក្សីដែលគួរឱ្យទុកចិត្ត និងការពារហ្វូងសត្វរបស់អ្នកដោយភាពច្បាស់លាស់ពីអ្នកជំនាញ។',
      'label_name': 'ឈ្មោះពេញ',
      'hint_name': 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'label_phone': 'លេខទូរស័ព្ទ',
      'hint_phone': '012 345 678',
      'label_password': 'ពាក្យសម្ងាត់',
      'hint_password': '••••••••',
      'label_village': 'ភូមិ',
      'hint_village': 'បញ្ចូលឈ្មោះភូមិរបស់អ្នក',
      'label_province': 'ខេត្ត / ក្រុង',
      'hint_province': 'បញ្ចូលឈ្មោះខេត្តរបស់អ្នក',
      'btn_submit': 'បញ្ចប់ការចុះឈ្មោះ',
      'footer_text': 'មានគណនីរួចហើយមែនទេ? ',
      'footer_link': 'ចូលគណនី',
      'err_name': 'សូមបញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'err_phone': 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
      'err_pass': 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់',
    },
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _villageController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return _localizedValues[widget.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  // Visual Form Input Builder following the sleek design image styling
  Widget _buildFormInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    const Color textDarkBlue = Color(0xFF0A1C33);
    const Color textGrey = Color(0xFF5A6B82);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: textDarkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: textDarkBlue, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textGrey.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: textGrey.withValues(alpha: 0.8),
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            errorStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0D6E28),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundLight = Color(0xFFF8FAFC);
    const Color brandDarkGreen = Color(
      0xFF034418,
    ); // Elegant deep action green matching image
    const Color brandHeaderGreen = Color(0xFF0D6E28);
    const Color textDarkBlue = Color(0xFF0A1C33);
    const Color textGrey = Color(0xFF5A6B82);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Header Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: textDarkBlue,
                        size: 26,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const Text(
                      'VacTracker',
                      style: TextStyle(
                        color: brandHeaderGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.language,
                        color: brandHeaderGreen,
                        size: 26,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Layout Headers
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
                  _getText('subtitle'),
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // 1. Full Name Inputs
                _buildFormInput(
                  label: _getText('label_name'),
                  hint: _getText('hint_name'),
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? _getText('err_name')
                      : null,
                ),

                // 2. Phone Number Inputs
                _buildFormInput(
                  label: _getText('label_phone'),
                  hint: _getText('hint_phone'),
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? _getText('err_phone')
                      : null,
                ),

                // 3. Password Input
                _buildFormInput(
                  label: _getText('label_password'),
                  hint: _getText('hint_password'),
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6
                      ? _getText('err_pass')
                      : null,
                ),

                // 4. Village Input
                _buildFormInput(
                  label: _getText('label_village'),
                  hint: _getText('hint_village'),
                  icon: Icons.home_work_outlined,
                  controller: _villageController,
                ),

                // 5. Province Input
                _buildFormInput(
                  label: _getText('label_province'),
                  hint: _getText('hint_province'),
                  icon: Icons.map_outlined,
                  controller: _provinceController,
                ),
                const SizedBox(height: 10),

                // Center Middle Illustration Placeholder matching the image template
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/welcome/Banner Section.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Custom Rounded Action Registration Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final backendLangPref = widget.languageCode == 'kh'
                            ? 'km'
                            : 'en';

                        final registrationPayload = {
                          "name": _nameController.text.trim(),
                          "phone": _phoneController.text.trim(),
                          "password": _passwordController.text,
                          "role": "farmer",
                          "village": _villageController.text.trim().isEmpty
                              ? null
                              : _villageController.text.trim(),
                          "province": _provinceController.text.trim().isEmpty
                              ? null
                              : _provinceController.text.trim(),
                          "language_pref": backendLangPref,
                        };

                        final router = GoRouter.of(context);
                        try {
                          final result = await authService.register(
                            registrationPayload,
                          );

                          debugPrint("Farmer Register success");
                          debugPrint(result.toString());

                          if (!mounted) return;
                          router.go('/login/farmer/${widget.languageCode}');
                        } catch (e) {
                          debugPrint("Register failed: $e");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: brandDarkGreen.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getText('btn_submit'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Log In Redirect Footer Segment
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: _getText('footer_text'),
                      style: const TextStyle(color: textGrey, fontSize: 15),
                      children: [
                        TextSpan(
                          text: _getText('footer_link'),
                          style: const TextStyle(
                            color: brandHeaderGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.go(
                                '/login/farmer/${widget.languageCode}',
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
