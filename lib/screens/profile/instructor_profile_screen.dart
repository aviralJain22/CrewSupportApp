import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/profile/cert_badge.dart';
import '../../widgets/profile/completion_bar.dart';
import '../../widgets/profile/profile_hero.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  // Personal
  final _nameCtrl = TextEditingController(text: 'James Holloway');
  final _emailCtrl = TextEditingController(text: 'j.holloway@flightinst.com');
  final _phoneCtrl = TextEditingController(text: '+1 602 555 0122');

  // Core certs
  final Map<String, bool> _certs = {
    'CFI': true, 'CFII': true, 'MEI': true, 'ATP': true, 'DPE': false,
  };

  final _certExpiry = {
    'CFI': DateTime(2026, 5, 14),
    'CFII': DateTime(2026, 5, 14),
    'MEI': DateTime(2026, 5, 14),
    'ATP': DateTime(2027, 1, 20),
  };

  // Endorsements
  final Map<String, bool> _endorsements = {
    'High Altitude': true,
    'Complex Aircraft': true,
    'Tailwheel': false,
    'Glider': false,
    'Seaplane': false,
    'Sport Pilot': false,
  };

  // Teaching preferences
  bool _groundOnly = false;
  bool _onlineAvailable = true;
  bool _checkRidePrep = true;
  bool _acceptsStudents = true;

  // Experience
  final _totalHoursCtrl = TextEditingController(text: '12000');
  final _instructionHoursCtrl = TextEditingController(text: '4500');
  final _studentsPassedCtrl = TextEditingController(text: '180');

  // Rates
  final _groundRateCtrl = TextEditingController(text: '80');
  final _flightRateCtrl = TextEditingController(text: '120');
  final _simRateCtrl = TextEditingController(text: '95');

  // Bio
  final _bioCtrl = TextEditingController();

  // Social
  final _instaCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  AppButtonState _saveState = AppButtonState.idle;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _totalHoursCtrl, _instructionHoursCtrl, _studentsPassedCtrl,
      _groundRateCtrl, _flightRateCtrl, _simRateCtrl,
      _bioCtrl, _instaCtrl, _linkedinCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _completionPercent {
    int filled = 0;
    final fields = [
      _nameCtrl.text, _emailCtrl.text, _phoneCtrl.text,
      _totalHoursCtrl.text, _instructionHoursCtrl.text, _groundRateCtrl.text,
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
    if (_bioCtrl.text.trim().isEmpty) m.add('Bio');
    if (_instaCtrl.text.isEmpty) m.add('Instagram');
    if (_linkedinCtrl.text.isEmpty) m.add('LinkedIn');
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Instructor Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          ProfileHero(
            name: _nameCtrl.text,
            role: 'Flight Instructor / CFI',
            avatarUrl: 'https://i.pravatar.cc/150?img=33',
            rating: 4.95,
            reviewCount: 62,
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
          _section('Endorsements', [
            _endorsementChips,
          ]),
          const SizedBox(height: 24),
          _section('Teaching Preferences', [
            _toggleRow(
              'Ground School Only',
              'No flight hours — ground / sim instruction only',
              _groundOnly,
              (v) => setState(() => _groundOnly = v),
            ),
            const SizedBox(height: 12),
            _toggleRow(
              'Online / Remote Available',
              'Ground lessons via video call',
              _onlineAvailable,
              (v) => setState(() => _onlineAvailable = v),
            ),
            const SizedBox(height: 12),
            _toggleRow(
              'Check-Ride Prep',
              'Specialised preparation for FAA check rides',
              _checkRidePrep,
              (v) => setState(() => _checkRidePrep = v),
            ),
            const SizedBox(height: 12),
            _toggleRow(
              'Accepting New Students',
              'Visible to students searching for instructors',
              _acceptsStudents,
              (v) => setState(() => _acceptsStudents = v),
            ),
          ]),
          const SizedBox(height: 24),
          _section('Experience', [
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Total Hours',
                  controller: _totalHoursCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Instruction Hours',
                  controller: _instructionHoursCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Students Passed Check Ride',
              controller: _studentsPassedCtrl,
              keyboardType: TextInputType.number,
            ),
          ]),
          const SizedBox(height: 24),
          _section('Rates (USD/hr)', [
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Ground Rate',
                  controller: _groundRateCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Colors.white38, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Flight Rate',
                  controller: _flightRateCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Colors.white38, size: 18),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Simulator Rate',
              controller: _simRateCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money,
                  color: Colors.white38, size: 18),
            ),
          ]),
          const SizedBox(height: 24),
          _section('Bio', [
            AppTextField(
              label: 'About Me',
              controller: _bioCtrl,
              hint: 'Describe your teaching philosophy…',
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
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

  Widget get _endorsementChips {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _endorsements.keys.map((key) {
        final active = _endorsements[key]!;
        return GestureDetector(
          onTap: () => setState(() => _endorsements[key] = !active),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active ? _gold.withValues(alpha: 0.12) : _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? _gold : _border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              key,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? _gold : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _toggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white38,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _gold,
          activeTrackColor: _gold.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: const Color(0xFF2A2520),
        ),
      ],
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
