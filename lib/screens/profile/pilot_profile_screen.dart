import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/profile/cert_badge.dart';
import '../../widgets/profile/completion_bar.dart';
import '../../widgets/profile/profile_hero.dart';

class PilotProfileScreen extends StatefulWidget {
  const PilotProfileScreen({super.key});

  @override
  State<PilotProfileScreen> createState() => _PilotProfileScreenState();
}

class _PilotProfileScreenState extends State<PilotProfileScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  // Personal
  final _nameCtrl = TextEditingController(text: 'Alexander Reid');
  final _emailCtrl = TextEditingController(text: 'alex.reid@aviator.com');
  final _phoneCtrl = TextEditingController(text: '+1 310 555 0147');

  // Certs
  final Map<String, bool> _certs = {
    'ATP': true, 'CPL': true, 'IR': true, 'ME': true, 'SE': false,
  };

  // Mock cert expiry for CertBadge display
  final _certExpiry = {
    'ATP': DateTime(2026, 9, 15),
    'CPL': DateTime(2025, 12, 1),
    'IR': DateTime(2027, 3, 20),
    'ME': DateTime(2026, 1, 10),
  };

  // Flight times
  final _totalHoursCtrl = TextEditingController(text: '8500');
  final _picCtrl = TextEditingController(text: '6200');
  final _complexCtrl = TextEditingController(text: '1800');
  final _hpCtrl = TextEditingController(text: '900');

  // Rates
  final _dayRateCtrl = TextEditingController(text: '1200');
  final _tripRateCtrl = TextEditingController(text: '3500');

  // Social
  final _instaCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  AppButtonState _saveState = AppButtonState.idle;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _totalHoursCtrl, _picCtrl, _complexCtrl, _hpCtrl,
      _dayRateCtrl, _tripRateCtrl, _instaCtrl, _linkedinCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _completionPercent {
    int filled = 0;
    final fields = [
      _nameCtrl.text, _emailCtrl.text, _phoneCtrl.text,
      _totalHoursCtrl.text, _picCtrl.text, _dayRateCtrl.text,
    ];
    for (final f in fields) {
      if (f.trim().isNotEmpty) filled++;
    }
    final certCount = _certs.values.where((v) => v).length;
    if (certCount > 0) filled++;
    return ((filled / (fields.length + 1)) * 100).round();
  }

  List<String> get _missingFields {
    final m = <String>[];
    if (_instaCtrl.text.isEmpty) m.add('Instagram');
    if (_linkedinCtrl.text.isEmpty) m.add('LinkedIn');
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Pilot Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          ProfileHero(
            name: _nameCtrl.text,
            role: 'Captain / Pilot in Command',
            avatarUrl: 'https://i.pravatar.cc/150?img=12',
            rating: 4.9,
            reviewCount: 47,
            onAvatarTap: () {},
          ),
          const SizedBox(height: 16),
          ProfileCompletionBar(
            percent: _completionPercent,
            missingFields: _missingFields,
          ),
          const SizedBox(height: 28),
          _section('Personal Info', [
            AppTextField(
              label: 'Full Name',
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Phone',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
          ]),
          const SizedBox(height: 24),
          _section('Certifications', [
            _certCheckboxes,
            const SizedBox(height: 16),
            _certBadgesRow,
          ]),
          const SizedBox(height: 24),
          _section('Flight Times', [
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Total Time (hrs)',
                  controller: _totalHoursCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'PIC (hrs)',
                  controller: _picCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Complex (hrs)',
                  controller: _complexCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'High Performance (hrs)',
                  controller: _hpCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 24),
          _section('Rates', [
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Day Rate (USD)',
                  controller: _dayRateCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Colors.white38, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Trip Rate (USD)',
                  controller: _tripRateCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Colors.white38, size: 18),
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 24),
          _section('Social Links', [
            AppTextField(
              label: 'Instagram',
              controller: _instaCtrl,
              hint: '@handle',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'LinkedIn',
              controller: _linkedinCtrl,
              hint: 'Profile URL',
              onChanged: (_) => setState(() {}),
            ),
          ]),
          const SizedBox(height: 32),
          AppButton(
            label: 'Save Changes',
            state: _saveState,
            onTap: _save,
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget get _certCheckboxes {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _certs.keys.map((cert) {
        final checked = _certs[cert]!;
        return GestureDetector(
          onTap: () => setState(() => _certs[cert] = !checked),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: checked ? _gold.withValues(alpha: 0.12) : _cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: checked ? _gold : _border,
                width: checked ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  checked
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 16,
                  color: checked ? _gold : Colors.white38,
                ),
                const SizedBox(width: 6),
                Text(
                  cert,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: checked ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget get _certBadgesRow {
    final active = _certExpiry.entries
        .where((e) => _certs[e.key] == true)
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: active
          .map((e) => CertBadge(name: e.key, expiryDate: e.value))
          .toList(),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 14),
          ...children,
        ],
      );

  Future<void> _save() async {
    setState(() => _saveState = AppButtonState.loading);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _saveState = AppButtonState.success);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _saveState = AppButtonState.idle);
  }
}
