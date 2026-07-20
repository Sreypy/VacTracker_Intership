import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class VetRegisterPage extends StatefulWidget {
  final String languageCode; // Router path flag passing 'en' or 'km'

  const VetRegisterPage({super.key, required this.languageCode});

  @override
  State<VetRegisterPage> createState() => _VetRegisterPageState();
}

class _VetRegisterPageState extends State<VetRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Backend Mapped Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _villageController = TextEditingController();
  final _provinceController = TextEditingController();
  final authService = AuthService();

  // Premium Localized Context Maps
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Create Vet Account',
      'subtitle':
          'Access professional tracking modules, manage livestock diagnostics, and coordinate response strategies.',
      'label_name': 'Full Name',
      'hint_name': 'Dr. Your Name',
      'label_phone': 'Phone Number',
      'hint_phone': '012 345 678',
      'label_password': 'Password',
      'hint_password': '••••••••',
      'label_village': 'Clinic Village',
      'hint_village': 'Enter clinic village operational zone',
      'label_province': 'Province / City',
      'hint_province': 'Select province assignment',
      'btn_submit': 'Complete Verification',
      'footer_text': 'Already registered? ',
      'footer_link': 'Log In',
      'err_name': 'Please enter your professional name',
      'err_phone': 'Please enter contact number',
      'err_pass': 'Security key must be at least 6 characters',
    },
    'km': {
      'title': 'បង្កើតគណនីបសុពេទ្យ',
      'subtitle':
          'ចូលប្រើប្រាស់ប្រព័ន្ធតាមដានកម្រិតអាជីព គ្រប់គ្រងការវិនិច្ឆ័យជំងឺសត្វ និងសម្របសម្រួលយុទ្ធសាស្ត្រឆ្លើយតប។',
      'label_name': 'ឈ្មោះពេញ',
      'hint_name': 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
      'label_phone': 'លេខទូរស័ព្ទ',
      'hint_phone': '012 345 678',
      'label_password': 'ពាក្យសម្ងាត់',
      'hint_password': '••••••••',
      'label_village': 'ភូមិប្រកបរបរ',
      'hint_village': 'បញ្ចូលឈ្មោះភូមិដែលគ្លីនិករបស់អ្នកស្ថិតនៅ',
      'label_province': 'ខេត្ត / ក្រុង',
      'hint_province': 'បញ្ចូលឈ្មោះខេត្តរបស់អ្នក',
      'btn_submit': 'បញ្ចប់ការចុះឈ្មោះ',
      'footer_text': 'មានគណនីរួចហើយមែនទេ? ',
      'footer_link': 'ចូលគណនី',
      'err_name': 'សូមបញ្ចូលឈ្មោះរបស់អ្នក',
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

  // Consistent Input Field Matrix Styling
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
              color: textGrey.withOpacity(0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, color: textGrey.withOpacity(0.8), size: 22),
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
    const Color brandDarkGreen = Color(0xFF034418);
    const Color brandHeaderGreen = Color(0xFF0D6E28);
    const Color textDarkBlue = Color(0xFF0A1C33);
    const Color textGrey = Color(0xFF5A6B82);

    // final isKhmer = widget.languageCode == 'km';

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
                // Clean Custom Global Header Bar Block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: textDarkBlue,
                        size: 26,
                      ),
                      onPressed: () => context.pop(),
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

                // Top Form Heading Header Texts
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

                // 1. Full Name Field Input Array
                _buildFormInput(
                  label: _getText('label_name'),
                  hint: _getText('hint_name'),
                  icon: Icons.medical_services_outlined,
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? _getText('err_name')
                      : null,
                ),

                // 2. Phone Number Field Input Array
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

                // 3. Password Field Input Array
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

                // 4. Village Field Input Array
                _buildFormInput(
                  label: _getText('label_village'),
                  hint: _getText('hint_village'),
                  icon: Icons.location_city_outlined,
                  controller: _villageController,
                ),

                // 5. Province Field Input Array
                _buildFormInput(
                  label: _getText('label_province'),
                  hint: _getText('hint_province'),
                  icon: Icons.map_outlined,
                  controller: _provinceController,
                ),
                const SizedBox(height: 10),

                // Visual Vet Operational Banner Asset Card Placeholder
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
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Unified Action Complete Registration Submission Area
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final registrationPayload = {
                          "name": _nameController.text.trim(),
                          "phone": _phoneController.text.trim(),
                          "password": _passwordController.text,
                          "role": "veterinarian",
                          "village": _villageController.text.trim().isEmpty
                              ? null
                              : _villageController.text.trim(),
                          "province": _provinceController.text.trim().isEmpty
                              ? null
                              : _provinceController.text.trim(),
                          "language_pref": widget.languageCode,
                        };

                        print(
                          "Clean TypeORM Structured Vet JSON Ready: $registrationPayload",
                        );

                        try {
                          final result = await authService.register(
                            registrationPayload,
                          );

                          print("Vet registration successful");
                          print(result);

                          if (!mounted) return;

                          context.go(
                            '/login/veterinarian/${widget.languageCode}',
                          );
                        } catch (error) {
                          print("Registration failed: $error");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: brandDarkGreen.withOpacity(0.3),
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

                // Context Routing Redirection Footer Elements
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
                                '/login/veterinarian/${widget.languageCode}',
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
