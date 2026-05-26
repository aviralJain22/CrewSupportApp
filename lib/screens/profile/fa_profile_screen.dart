import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/profile/cert_badge.dart';
import '../../widgets/profile/completion_bar.dart';
import '../../widgets/profile/profile_hero.dart';

class FaProfileScreen extends StatefulWidget {
  const FaProfileScreen({super.key});

  @override
  State<FaProfileScreen> createState() => _FaProfileScreenState();
}

class _FaProfileScreenState extends State<FaProfileScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  // Personal
  final _nameCtrl = TextEditingController(text: 'Sophia Lane');
  final _emailCtrl = TextEditingController(text: 'sophia.lane@cabincrew.com');
  final _phoneCtrl = TextEditingController(text: '+1 424 555 0183');

  // Certs
  final Map<String, bool> _certs = {
    'FAA FA': true,
    'CPR/AED': true,
    'EASA Cabin': false,
    'Dangerous Goods': true,
    'HUET': false,
  };

  final _certExpiry = {
    'FAA FA': DateTime(2026, 8, 10),
    'CPR/AED': DateTime(2025, 11, 5),
    'Dangerous Goods': DateTime(2027, 2, 18),
  };

  // Work preferences
  bool _isFullTime = true;
  final Map<String, bool> _flightTypes = {
    'Private Charter': true,
    'Corporate': true,
    'Ultra-Long Range': false,
    'International': false,
    'Domestic': true,
  };
  final Map<String, bool> _aircraftTypes = {
    'Heavy Jets': true,
    'Mid Jets': true,
    'Light Jets': false,
    'Turboprop': false,
  };

  // Experience
  final _yearsExpCtrl = TextEditingController(text: '7');
  final _totalFlightsCtrl = TextEditingController(text: '1200');
  final _languagesCtrl = TextEditingController(text: 'English, French');

  // Rates
  final _dayRateCtrl = TextEditingController(text: '650');
  final _tripRateCtrl = TextEditingController(text: '1800');

  // Social
  final _instaCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  AppButtonState _saveState = AppButtonState.idle;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _yearsExpCtrl, _totalFlightsCtrl, _languagesCtrl,
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
      _yearsExpCtrl.text, _languagesCtrl.text, _dayRateCtrl.text,
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
    if (_languagesCtrl.text.isEmpty) m.add('Languages');
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'FA Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          ProfileHero(
            name: _nameCtrl.text,
            role: 'Flight Attendant / Cabin Crew',
            avatarUrl: 'https://i.pravatar.cc/150?img=47',
            rating: 4.8,
            reviewCount: 31,
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
          _section('Work Preferences', [
            _employmentToggle,
            const SizedBox(height: 20),
            _subsection('Flight Types'),
            const SizedBox(height: 10),
            _multiSelectChips(_flightTypes),
            const SizedBox(height: 20),
            _subsection('Aircraft'),
            const SizedBox(height: 10),
            _multiSelectChips(_aircraftTypes),
          ]),
          const SizedBox(height: 24),
          _section('Experience', [
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Years Experience',
                  controller: _yearsExpCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Total Flights',
                  controller: _totalFlightsCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Languages',
              controller: _languagesCtrl,
              hint: 'e.g. English, French',
              onChanged: (_) => setState(() {}),
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    fontSize: 12,
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

  Widget get _employmentToggle {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability Type',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _employmentOption('Full-Time', true),
              const SizedBox(width: 10),
              _employmentOption('Part-Time', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _employmentOption(String label, bool isFullTime) {
    final selected = _isFullTime == isFullTime;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isFullTime = isFullTime),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _gold.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? _gold : _border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? _gold : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _multiSelectChips(Map<String, bool> map) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: map.keys.map((key) {
        final selected = map[key]!;
        return GestureDetector(
          onTap: () => setState(() => map[key] = !selected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? _gold.withValues(alpha: 0.12) : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _gold : _border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              key,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? _gold : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _subsection(String label) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      );

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
