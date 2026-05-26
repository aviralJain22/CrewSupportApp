import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/profile/completion_bar.dart';
import '../../widgets/profile/profile_hero.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);

  // Personal info
  final _nameCtrl = TextEditingController(text: 'Charter Wings LLC');
  final _emailCtrl = TextEditingController(text: 'ops@charterwings.com');
  final _phoneCtrl = TextEditingController(text: '+1 212 555 0190');
  final _companyCtrl = TextEditingController(text: 'Charter Wings LLC');

  // About
  final _bioCtrl = TextEditingController();

  // Location
  final _cityCtrl = TextEditingController(text: 'New York, NY');
  final _baseCtrl = TextEditingController(text: 'KTEB');
  bool _locationVisible = true;

  // Social
  final _instaCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  AppButtonState _saveState = AppButtonState.idle;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl, _companyCtrl,
      _bioCtrl, _cityCtrl, _baseCtrl,
      _instaCtrl, _fbCtrl, _linkedinCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _completionPercent {
    int filled = 0;
    final fields = [
      _nameCtrl.text, _emailCtrl.text, _phoneCtrl.text,
      _bioCtrl.text, _cityCtrl.text,
    ];
    for (final f in fields) {
      if (f.trim().isNotEmpty) filled++;
    }
    return ((filled / fields.length) * 100).round();
  }

  List<String> get _missingFields {
    final missing = <String>[];
    if (_bioCtrl.text.trim().isEmpty) missing.add('Bio');
    if (_instaCtrl.text.trim().isEmpty) missing.add('Instagram');
    if (_fbCtrl.text.trim().isEmpty) missing.add('Facebook');
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Owner Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          ProfileHero(
            name: _nameCtrl.text,
            role: 'Aircraft Owner / Operator',
            avatarUrl: 'https://i.pravatar.cc/150?img=60',
            readOnly: false,
            onAvatarTap: () {},
          ),
          const SizedBox(height: 20),
          ProfileCompletionBar(
            percent: _completionPercent,
            missingFields: _missingFields,
          ),
          const SizedBox(height: 28),
          _section('Personal Info', [
            AppTextField(
              label: 'Full Name / Company',
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
            const SizedBox(height: 14),
            AppTextField(
              label: 'Company / Fleet Name',
              controller: _companyCtrl,
            ),
          ]),
          const SizedBox(height: 24),
          _section('About', [
            AppTextField(
              label: 'Bio',
              controller: _bioCtrl,
              hint: 'Tell crew about your operation…',
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
          ]),
          const SizedBox(height: 24),
          _section('Location', [
            AppTextField(
              label: 'Base City',
              controller: _cityCtrl,
              prefixIcon: const Icon(Icons.location_city_outlined,
                  color: Colors.white38, size: 18),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Home Base Airport (ICAO)',
              controller: _baseCtrl,
              textCapitalization: TextCapitalization.characters,
              prefixIcon: const Icon(Icons.flight_rounded,
                  color: Colors.white38, size: 18),
            ),
            const SizedBox(height: 16),
            _locationToggle,
          ]),
          const SizedBox(height: 24),
          _section('Social Links', [
            AppTextField(
              label: 'Instagram',
              controller: _instaCtrl,
              hint: '@handle',
              prefixIcon: const Icon(Icons.alternate_email_rounded,
                  color: Colors.white38, size: 18),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Facebook',
              controller: _fbCtrl,
              hint: 'Profile URL',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'LinkedIn',
              controller: _linkedinCtrl,
              hint: 'Profile URL',
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

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }

  Widget get _locationToggle => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show location to crew',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Crew can see your city when browsing',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _locationVisible,
            onChanged: (v) => setState(() => _locationVisible = v),
            activeThumbColor: _gold,
            activeTrackColor: _gold.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: const Color(0xFF2A2520),
          ),
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
