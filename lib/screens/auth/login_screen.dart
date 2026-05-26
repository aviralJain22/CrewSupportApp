import 'dart:convert';
import 'package:crew_support/utils/app_spacing.dart';
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
  static const _bg     = Color(0xFF0C0A06);
  static const _gold   = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

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
    if (_autoLoggingIn) return _buildAutoLogin(context);

    final hPad   = AppSpacing.screenH(context);
    final topGap = AppSpacing.xxxl(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topGap),
              _buildLogo(context),
              SizedBox(height: AppSpacing.xxl(context)),
              _buildMembershipDropdown(context),
              SizedBox(height: AppSpacing.md(context)),
              _buildEmailField(context),
              SizedBox(height: AppSpacing.md(context)),
              _buildPasswordField(context),
              SizedBox(height: AppSpacing.sm(context) + 2),
              _buildForgotRow(),
              SizedBox(height: AppSpacing.md(context)),
              _buildRememberMeCard(context),
              SizedBox(height: AppSpacing.xl(context)),
              _buildSignInBtn(context),
              SizedBox(height: AppSpacing.lg(context)),
              _buildDivider(context),
              SizedBox(height: AppSpacing.lg(context)),
              _buildJoinNowBtn(context),
              SizedBox(height: AppSpacing.xxl(context)),
              _buildHelpCenter(context),
              SizedBox(height: AppSpacing.xl(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logo ─────────────────────────────────────────────────────────────────

  Widget _buildLogo(BuildContext context) {
    final logoSize = AppSpacing.avatarLg(context) + 10;
    final logoIconSize = logoSize * 0.51;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C2200), Color(0xFF1A1500)],
            ),
            borderRadius: BorderRadius.circular(logoSize * 0.27),
            border: Border.all(
                color: _gold.withValues(alpha: 0.65), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.flight_rounded, color: _gold, size: logoIconSize),
        ),
        SizedBox(height: AppSpacing.md(context)),
        Text(
          'CREW',
          style: GoogleFonts.cinzel(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _gold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: AppSpacing.xxs(context)),
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

  Widget _buildMembershipDropdown(BuildContext context) {
    final fieldH = AppSpacing.fieldH(context);
    final hPad   = AppSpacing.md(context);
    final iconGap = AppSpacing.sm(context);
    final iconSize = AppSpacing.iconMd(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Membership Type'),
        SizedBox(height: AppSpacing.sm(context)),
        _fieldShell(
          height: fieldH,
          child: Row(
            children: [
              SizedBox(width: hPad),
              Icon(Icons.person_outline_rounded, color: _gold, size: iconSize),
              SizedBox(width: iconGap),
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
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38, size: iconSize),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white),
                    items: _membershipTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _membershipType = v),
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

  Widget _buildEmailField(BuildContext context) {
    final fieldH   = AppSpacing.fieldH(context);
    final hPad     = AppSpacing.md(context);
    final iconGap  = AppSpacing.sm(context);
    final iconSize = AppSpacing.iconMd(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Email / Phone'),
        SizedBox(height: AppSpacing.sm(context)),
        _fieldShell(
          height: fieldH,
          child: Row(
            children: [
              SizedBox(width: hPad),
              Icon(Icons.mail_outline_rounded, color: _gold, size: iconSize),
              SizedBox(width: iconGap),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
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
              SizedBox(width: hPad),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  Widget _buildPasswordField(BuildContext context) {
    final fieldH   = AppSpacing.fieldH(context);
    final hPad     = AppSpacing.md(context);
    final iconGap  = AppSpacing.sm(context);
    final iconSize = AppSpacing.iconMd(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Password'),
        SizedBox(height: AppSpacing.sm(context)),
        _fieldShell(
          height: fieldH,
          child: Row(
            children: [
              SizedBox(width: hPad),
              Icon(Icons.lock_outline_rounded, color: _gold, size: iconSize),
              SizedBox(width: iconGap),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVis,
                  onChanged: (_) => setState(() {}),
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
                onTap: () => setState(() => _passwordVis = !_passwordVis),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Icon(
                    _passwordVis
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: iconSize,
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

  Widget _buildRememberMeCard(BuildContext context) {
    final hPad       = AppSpacing.md(context);
    final vPad       = AppSpacing.sm(context) + 2;
    final checkSize  = AppSpacing.iconMd(context) + 2;
    final checkGap   = AppSpacing.sm(context) + 2;
    final shieldGap  = AppSpacing.sm(context);
    final shieldSize = AppSpacing.iconMd(context) + 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _rememberMe = !_rememberMe);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: _rememberMe ? _gold.withValues(alpha: 0.06) : _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _rememberMe ? _gold.withValues(alpha: 0.5) : _border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: checkSize,
              height: checkSize,
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
                  ? Icon(Icons.check_rounded,
                      size: checkSize * 0.6, color: _gold)
                  : null,
            ),
            SizedBox(width: checkGap),
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
                  SizedBox(height: AppSpacing.xxs(context)),
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
            SizedBox(width: shieldGap),
            Icon(
              _rememberMe ? Icons.shield_rounded : Icons.shield_outlined,
              color: _rememberMe ? _gold : Colors.white24,
              size: shieldSize,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sign In button ───────────────────────────────────────────────────────

  Widget _buildSignInBtn(BuildContext context) {
    final btnH       = AppSpacing.buttonH(context);
    final spinnerSz  = AppSpacing.iconLg(context);

    return GestureDetector(
      onTap: _canSubmit && !_loading ? _signIn : null,
      child: Container(
        width: double.infinity,
        height: btnH,
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
          border: _canSubmit ? null : Border.all(color: _border),
        ),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: spinnerSz,
                  height: spinnerSz,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _canSubmit ? const Color(0xFF0C0A08) : Colors.white24,
                    ),
                  ),
                )
              : Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        _canSubmit ? const Color(0xFF0C0A08) : Colors.white24,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md(context)),
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
        const Expanded(child: Divider(color: _border)),
      ],
    );
  }

  // ─── Join Now ─────────────────────────────────────────────────────────────

  Widget _buildJoinNowBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.signupNew),
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonH(context),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: _gold.withValues(alpha: 0.7), width: 1.5),
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

  Widget _buildHelpCenter(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.headset_mic_outlined,
              color: _gold, size: AppSpacing.iconMd(context)),
          SizedBox(width: AppSpacing.sm(context)),
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

  Widget _buildAutoLogin(BuildContext context) {
    final circleSize = AppSpacing.avatarLg(context);
    final iconSize   = circleSize * 0.47;
    final barWidth   = AppSpacing.xxxl(context) + 20;

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C2200), Color(0xFF1A1500)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Icon(Icons.flight_rounded, color: _gold, size: iconSize),
            ),
            SizedBox(height: AppSpacing.xl(context)),
            Text(
              'CREW SUPPORT',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              'Signing you in…',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
            ),
            SizedBox(height: AppSpacing.xxl(context)),
            AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, _) => Container(
                width: barWidth,
                height: 3,
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

  Widget _fieldShell({required Widget child, required double height}) =>
      Container(
        height: height,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: child,
      );
}
