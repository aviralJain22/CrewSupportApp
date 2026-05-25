import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _emailError = false;
  bool _passwordError = false;
  AppButtonState _btnState = AppButtonState.idle;

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());

  Future<void> _signIn() async {
    final emailOk = _isValidEmail(_emailCtrl.text);
    final passOk = _passwordCtrl.text.length >= 6;
    if (!emailOk || !passOk) {
      setState(() {
        _emailError = !emailOk;
        _passwordError = !passOk;
      });
      return;
    }
    setState(() {
      _emailError = false;
      _passwordError = false;
      _btnState = AppButtonState.loading;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _btnState = AppButtonState.success);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _logo,
              const SizedBox(height: 44),
              Text(
                'Welcome back',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 36),
              AppTextField(
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                hint: 'you@example.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: Colors.white38, size: 18),
                onChanged: (_) => setState(() {
                  _emailError = false;
                }),
                errorText: _emailError ? 'Enter a valid email address' : null,
              ),
              const SizedBox(height: 16),
              _passwordField,
              const SizedBox(height: 14),
              _rememberForgotRow,
              const SizedBox(height: 28),
              AppButton(
                label: 'Sign In',
                state: _canSubmit ? _btnState : AppButtonState.disabled,
                onTap: _signIn,
                width: double.infinity,
                height: 54,
              ),
              const SizedBox(height: 24),
              _divider,
              const SizedBox(height: 24),
              _socialRow,
              const SizedBox(height: 28),
              _signUpRow,
              const SizedBox(height: 24),
              _terms,
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _logo => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _gold.withValues(alpha: 0.35)),
            ),
            child: const Icon(Icons.flight_rounded, color: _gold, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'CrewSupport',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      );

  Widget get _passwordField {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _passwordError ? const Color(0xFFB33A3A) : Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _passwordError
                  ? const Color(0xFFB33A3A)
                  : const Color(0xFF2A2520),
              width: _passwordError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVisible,
                  onChanged: (_) => setState(() => _passwordError = false),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  cursorColor: _gold,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white24),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    _passwordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_passwordError) ...[
          const SizedBox(height: 6),
          Text(
            'Password must be at least 6 characters',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFFB33A3A),
            ),
          ),
        ],
      ],
    );
  }

  Widget get _rememberForgotRow => Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _rememberMe
                        ? _gold.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _rememberMe ? _gold : const Color(0xFF3A3530),
                      width: _rememberMe ? 1.5 : 1,
                    ),
                  ),
                  child: _rememberMe
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Color(0xFFD4AF37))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Forgot password?',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _gold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );

  Widget get _divider => Row(
        children: [
          Expanded(child: Divider(color: _border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'or continue with',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
            ),
          ),
          Expanded(child: Divider(color: _border)),
        ],
      );

  Widget get _socialRow => Row(
        children: [
          _socialBtn('Google', Icons.g_mobiledata_rounded),
          const SizedBox(width: 12),
          _socialBtn('Apple', Icons.apple_rounded),
        ],
      );

  Widget _socialBtn(String label, IconData icon) => Expanded(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget get _signUpRow => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Sign up',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget get _terms => Center(
        child: Text(
          'By continuing you agree to our Terms of Service\nand Privacy Policy.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white24,
            height: 1.6,
          ),
        ),
      );
}
