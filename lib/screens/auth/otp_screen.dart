import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/auth/otp_input.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);

  String _otp = '';
  bool _hasError = false;
  AppButtonState _btnState = AppButtonState.idle;

  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() {
      _hasError = false;
      _btnState = AppButtonState.loading;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Mock: any code other than 123456 is an error
    if (_otp != '123456') {
      setState(() {
        _hasError = true;
        _btnState = AppButtonState.idle;
      });
      return;
    }
    setState(() => _btnState = AppButtonState.success);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
  }

  String get _phoneDisplay {
    final p = widget.phone ?? '';
    if (p.length <= 4) return p;
    return '${p.substring(0, p.length - 4)}••••';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Verify your number',
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the 6-digit code sent to $_phoneDisplay',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              OtpInput(
                length: 6,
                hasError: _hasError,
                onChanged: (v) => setState(() {
                  _otp = v;
                  _hasError = false;
                }),
                onCompleted: (v) {
                  _otp = v;
                  _verify();
                },
              ),
              if (_hasError) ...[
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Incorrect code. Please try again.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFFB33A3A),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 36),
              AppButton(
                label: 'Verify',
                state: _otp.length == 6
                    ? _btnState
                    : AppButtonState.disabled,
                onTap: _verify,
                width: double.infinity,
                height: 54,
              ),
              const SizedBox(height: 28),
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend code in ${_resendSeconds}s',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white38,
                        ),
                      )
                    : GestureDetector(
                        onTap: _startTimer,
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _gold,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: _gold,
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
}
