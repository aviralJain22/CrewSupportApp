import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _bg       = Color(0xFF0C0A06);
  static const _gold     = Color(0xFFD4AF37);
  static const _cardBg   = Color(0xFF181410);
  static const _border   = Color(0xFF2A2520);

  static const _keyRememberMe    = 'cs_remember_me';
  static const _keySavedEmail    = 'cs_saved_email';
  static const _keySavedPassword = 'cs_saved_password';
  static const _keySessionActive = 'cs_session_active';

  static const _membershipTypes = [
    'Owner',
    'Pilot / Captain',
    'Flight Attendant',
  ];

  String? _membershipType;
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVis   = false;
  bool _rememberMe    = false;
  bool _loading       = false;
  bool _autoLoggingIn = false;

  late final AnimationController _shimmerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ─── Session logic ────────────────────────────────────────────────────────

  Future<void> _checkSavedSession() async {
    final prefs         = await SharedPreferences.getInstance();
    final rememberMe    = prefs.getBool(_keyRememberMe)      ?? false;
    final sessionActive = prefs.getBool(_keySessionActive)   ?? false;
    final savedEmail    = prefs.getString(_keySavedEmail)    ?? '';
    final savedPassEnc  = prefs.getString(_keySavedPassword) ?? '';

    if (!rememberMe) return;

    if (savedEmail.isNotEmpty) {
      String decoded = '';
      if (savedPassEnc.isNotEmpty) {
        try { decoded = utf8.decode(base64Decode(savedPassEnc)); } catch (_) {}
      }
      setState(() {
        _emailCtrl.text    = savedEmail;
        _passwordCtrl.text = decoded;
        _rememberMe        = true;
      });
    }

    if (sessionActive && savedEmail.isNotEmpty) {
      setState(() => _autoLoggingIn = true);
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.mainShell);
    }
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      final enc = base64Encode(utf8.encode(_passwordCtrl.text));
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setString(_keySavedEmail, _emailCtrl.text.trim());
      await prefs.setString(_keySavedPassword, enc);
      await prefs.setBool(_keySessionActive, true);
    } else {
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keySavedEmail);
      await prefs.remove(_keySavedPassword);
      await prefs.remove(_keySessionActive);
    }
  }

  Future<void> _signIn() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    await _persistSession();
    Get.offAllNamed(AppRoutes.mainShell);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_autoLoggingIn) return _buildAutoLogin();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 44),
              _buildLogo(),
              const SizedBox(height: 36),
              _buildMembershipDropdown(),
              const SizedBox(height: 14),
              _buildEmailField(),
              const SizedBox(height: 14),
              _buildPasswordField(),
              const SizedBox(height: 10),
              _buildForgotRow(),
              const SizedBox(height: 14),
              _buildRememberMeCard(),
              const SizedBox(height: 24),
              _buildSignInBtn(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildJoinNowBtn(),
              const SizedBox(height: 28),
              _buildHelpCenter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logo ─────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 82, height: 82,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C2200),
                const Color(0xFF1A1500),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _gold.withValues(alpha: 0.65), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.flight_rounded, color: _gold, size: 42),
        ),
        const SizedBox(height: 14),
        Text(
          'CREW',
          style: GoogleFonts.cinzel(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'SUPPORT',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _gold,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }

  // ─── Membership dropdown ──────────────────────────────────────────────────

  Widget _buildMembershipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Membership Type'),
        const SizedBox(height: 8),
        _fieldShell(
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.person_outline_rounded,
                  color: _gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _membershipType,
                    hint: Text(
                      'Select Type',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.white38),
                    ),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1B17),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38, size: 20),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white),
                    items: _membershipTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _membershipType = v),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Email / Phone ────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Email / Phone'),
        const SizedBox(height: 8),
        _fieldShell(
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.mail_outline_rounded,
                  color: _gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.white),
                  cursorColor: _gold,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email or phone number',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white38),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Password'),
        const SizedBox(height: 8),
        _fieldShell(
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.lock_outline_rounded,
                  color: _gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVis,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.white),
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
                    setState(() => _passwordVis = !_passwordVis),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    _passwordVis
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Forgot row ───────────────────────────────────────────────────────────

  Widget _buildForgotRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _gold,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Remember Me card ─────────────────────────────────────────────────────

  Widget _buildRememberMeCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _rememberMe = !_rememberMe);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _rememberMe
              ? _gold.withValues(alpha: 0.06)
              : _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _rememberMe
                ? _gold.withValues(alpha: 0.5)
                : _border,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: _rememberMe
                    ? _gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: _rememberMe ? _gold : Colors.white38,
                  width: 1.5,
                ),
              ),
              child: _rememberMe
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: _gold)
                  : null,
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remember Me',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _rememberMe ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save my login info for faster access',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Shield icon
            Icon(
              _rememberMe
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              color: _rememberMe ? _gold : Colors.white24,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sign In button ───────────────────────────────────────────────────────

  Widget _buildSignInBtn() {
    return GestureDetector(
      onTap: _canSubmit && !_loading ? _signIn : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _canSubmit
              ? const LinearGradient(
                  colors: [Color(0xFFE8C547), Color(0xFFB8960C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _canSubmit ? null : const Color(0xFF1E1B17),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _canSubmit
              ? [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: _canSubmit
              ? null
              : Border.all(color: _border),
        ),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _canSubmit
                          ? const Color(0xFF0C0A08)
                          : Colors.white24,
                    ),
                  ),
                )
              : Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _canSubmit
                        ? const Color(0xFF0C0A08)
                        : Colors.white24,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: _border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: _border)),
      ],
    );
  }

  // ─── Join Now ─────────────────────────────────────────────────────────────

  Widget _buildJoinNowBtn() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.signupNew),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.5),
        ),
        child: Center(
          child: Text(
            'Join Now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _gold,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Help Center ──────────────────────────────────────────────────────────

  Widget _buildHelpCenter() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.headset_mic_outlined, color: _gold, size: 18),
          const SizedBox(width: 8),
          Text(
            'Help Center',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _gold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Auto-login shimmer ───────────────────────────────────────────────────

  Widget _buildAutoLogin() {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2C2200), const Color(0xFF1A1500)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.flight_rounded, color: _gold, size: 34),
            ),
            const SizedBox(height: 22),
            Text(
              'CREW SUPPORT',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Signing you in…',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, _) => Container(
                width: 120, height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      _gold.withValues(alpha: 0),
                      _gold.withValues(alpha: 0.8),
                      _gold.withValues(alpha: 0),
                    ],
                    stops: [
                      (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                      _shimmerCtrl.value.clamp(0.0, 1.0),
                      (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      );

  Widget _fieldShell({required Widget child}) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: child,
      );
}
