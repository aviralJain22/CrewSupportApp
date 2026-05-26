import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../services/user_session.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _bg     = Color(0xFF0C0A06);
  static const _gold   = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);
  static const _error  = Color(0xFFB33A3A);

  static const _membershipOptions = ['Owner', 'Pilot / Captain', 'Flight Attendant'];
  static const _genderOptions     = ['Male', 'Female', 'Prefer not to say'];
  static const _countryCodes      = [
    _CountryCode('🇺🇸', 'US', '+1'),
    _CountryCode('🇬🇧', 'GB', '+44'),
    _CountryCode('🇮🇳', 'IN', '+91'),
    _CountryCode('🇦🇪', 'AE', '+971'),
    _CountryCode('🇦🇺', 'AU', '+61'),
    _CountryCode('🇸🇬', 'SG', '+65'),
    _CountryCode('🇨🇦', 'CA', '+1'),
  ];

  String? _membership;
  String? _gender;
  _CountryCode _countryCode = _countryCodes.first;

  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _passVis    = false;
  bool _confirmVis = false;
  bool _terms      = false;
  bool _loading    = false;
  bool _submitted  = false;

  // ─── Validation ──────────────────────────────────────────────────────────

  bool get _memberErr   => _submitted && _membership == null;
  bool get _genderErr   => _submitted && _gender == null;
  bool get _firstErr    => _submitted && _firstCtrl.text.trim().isEmpty;
  bool get _lastErr     => _submitted && _lastCtrl.text.trim().isEmpty;
  bool get _emailErr    => _submitted && !_validEmail(_emailCtrl.text);
  bool get _phoneErr    => _submitted && _phoneCtrl.text.trim().length < 7;
  bool get _passErr     => _submitted && _passCtrl.text.length < 6;
  bool get _confirmErr  => _submitted && _confirmCtrl.text != _passCtrl.text;
  bool get _termsErr    => _submitted && !_terms;

  bool _validEmail(String v) =>
      RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_memberErr || _genderErr || _firstErr || _lastErr ||
        _emailErr || _phoneErr || _passErr || _confirmErr || _termsErr) {
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    await UserSession.instance.save(
      role: _membership!,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
    );
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.mainShell);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownRow(
                      label: 'Membership Type',
                      value: _membership,
                      items: _membershipOptions,
                      hint: 'Select Type',
                      hasError: _memberErr,
                      onChanged: (v) => setState(() => _membership = v),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownRow(
                      label: 'Gender',
                      value: _gender,
                      items: _genderOptions,
                      hint: 'Select Gender',
                      hasError: _genderErr,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 10),
                    _buildTextRow(
                      label: 'First Name',
                      ctrl: _firstCtrl,
                      hint: 'First Name',
                      hasError: _firstErr,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _buildTextRow(
                      label: 'Last Name',
                      ctrl: _lastCtrl,
                      hint: 'Last Name',
                      hasError: _lastErr,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _buildTextRow(
                      label: 'Email Address',
                      ctrl: _emailCtrl,
                      hint: 'Email',
                      hasError: _emailErr,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _buildCountryCodeRow(),
                    const SizedBox(height: 10),
                    _buildTextRow(
                      label: 'Phone Number',
                      ctrl: _phoneCtrl,
                      hint: 'Phone Number',
                      hasError: _phoneErr,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.smartphone_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordRow(
                      label: 'Password',
                      ctrl: _passCtrl,
                      visible: _passVis,
                      hint: 'Password',
                      hasError: _passErr,
                      onToggle: () =>
                          setState(() => _passVis = !_passVis),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordRow(
                      label: 'Confirm Password',
                      ctrl: _confirmCtrl,
                      visible: _confirmVis,
                      hint: 'Confirm Password',
                      hasError: _confirmErr,
                      onToggle: () =>
                          setState(() => _confirmVis = !_confirmVis),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    _buildTermsRow(),
                    if (_termsErr) ...[
                      const SizedBox(height: 6),
                      Text(
                        'You must accept the terms to continue',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: _error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildSubmitBtn(),
                    const SizedBox(height: 20),
                    _buildSignInRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: _gold, size: 16),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'CREATE AN ACCOUNT',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Fill in your details to get started',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 36), // balance back button
        ],
      ),
    );
  }

  // ─── Dropdown row ─────────────────────────────────────────────────────────

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required bool hasError,
    required ValueChanged<String?> onChanged,
  }) {
    return _rowShell(
      hasError: hasError,
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1B17),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38, size: 20),
                hint: Text(hint,
                    style: GoogleFonts.inter(
                        fontSize: 13.5, color: Colors.white38)),
                style: GoogleFonts.inter(
                    fontSize: 13.5, color: Colors.white),
                items: items
                    .map((i) =>
                        DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Text row ─────────────────────────────────────────────────────────────

  Widget _buildTextRow({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required bool hasError,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return _rowShell(
      hasError: hasError,
      child: Row(
        children: [
          const SizedBox(width: 16),
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: _gold, size: 18),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: prefixIcon != null ? 112 : 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                  fontSize: 13.5, color: Colors.white),
              cursorColor: _gold,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                    fontSize: 13.5, color: Colors.white38),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  // ─── Country code row ─────────────────────────────────────────────────────

  Widget _buildCountryCodeRow() {
    return _rowShell(
      hasError: false,
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.language_outlined, color: _gold, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 112,
            child: Text(
              'Country Code',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_CountryCode>(
                value: _countryCode,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1B17),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38, size: 18),
                style: GoogleFonts.inter(
                    fontSize: 13.5, color: Colors.white),
                items: _countryCodes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                              '${c.flag} ${c.code} ${c.dial}'),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _countryCode = v!),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Password row ─────────────────────────────────────────────────────────

  Widget _buildPasswordRow({
    required String label,
    required TextEditingController ctrl,
    required bool visible,
    required String hint,
    required bool hasError,
    required VoidCallback onToggle,
    required ValueChanged<String> onChanged,
  }) {
    return _rowShell(
      hasError: hasError,
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.lock_outline_rounded, color: _gold, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: !visible,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                  fontSize: 13.5, color: Colors.white),
              cursorColor: _gold,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                    fontSize: 13.5, color: Colors.white38),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Terms row ────────────────────────────────────────────────────────────

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _terms = !_terms);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: _terms
                  ? _gold.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _termsErr
                    ? _error
                    : _terms
                        ? _gold
                        : Colors.white38,
                width: 1.5,
              ),
            ),
            child: _terms
                ? const Icon(Icons.check_rounded,
                    size: 14, color: _gold)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: Colors.white60),
                children: [
                  const TextSpan(text: 'I accept '),
                  TextSpan(
                    text: 'Terms of use',
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: _gold,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: _gold,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Disclaimer',
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: _gold,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit button ────────────────────────────────────────────────────────

  Widget _buildSubmitBtn() {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8C547), Color(0xFFB8960C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0C0A08)),
                  ),
                )
              : Text(
                  'Submit',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C0A08),
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Sign in row ──────────────────────────────────────────────────────────

  Widget _buildSignInRow() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.white38),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Text(
              'Sign In',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _rowShell({required bool hasError, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? _error : _border,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

// ─── Country code model ───────────────────────────────────────────────────────

class _CountryCode {
  const _CountryCode(this.flag, this.code, this.dial);
  final String flag, code, dial;

  @override
  bool operator ==(Object other) =>
      other is _CountryCode && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
