import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/role_card.dart';
import '../../widgets/shared/step_indicator.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);

  int _step = 1;
  static const _totalSteps = 4;
  static const _stepLabels = ['Roles', 'Route', 'Date', 'Review'];

  // Step 1 - roles
  final Set<String> _selectedRoles = {};

  // Step 2 - route
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _fromError, _toError;

  // Step 3 - date
  DateTime? _departDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  String? _dateError;

  // Step 4 - review state
  AppButtonState _submitState = AppButtonState.idle;

  final _roles = [
    (
      icon: Icons.flight_takeoff_rounded,
      title: 'Captain',
      desc: 'Pilot in command. FAA ATP certificate required.',
    ),
    (
      icon: Icons.flight_rounded,
      title: 'SIC',
      desc: 'Second in command. Commercial certificate required.',
    ),
    (
      icon: Icons.airline_seat_recline_extra_rounded,
      title: 'Flight Attendant',
      desc: 'Cabin crew to ensure passenger safety and comfort.',
    ),
    (
      icon: Icons.school_rounded,
      title: 'Flight Instructor',
      desc: 'CFI for training flights and recurrencies.',
    ),
  ];

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed => switch (_step) {
        1 => _selectedRoles.isNotEmpty,
        2 => _fromCtrl.text.trim().isNotEmpty &&
            _toCtrl.text.trim().isNotEmpty,
        3 => _departDate != null,
        _ => true,
      };

  void _next() {
    if (_step == 2) {
      setState(() {
        _fromError = _fromCtrl.text.trim().isEmpty ? 'Origin is required' : null;
        _toError = _toCtrl.text.trim().isEmpty ? 'Destination is required' : null;
      });
      if (_fromError != null || _toError != null) return;
    }
    if (_step == 3 && _departDate == null) {
      setState(() => _dateError = 'Please select a departure date');
      return;
    }
    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      _submitTrip();
    }
  }

  void _submitTrip() async {
    setState(() => _submitState = AppButtonState.loading);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _submitState = AppButtonState.success);
    await Future.delayed(const Duration(milliseconds: 800));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: StepIndicator(
              totalSteps: _totalSteps,
              currentStep: _step,
              labels: _stepLabels,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _buildStep(),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  AppBar get _appBar => AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              Get.back();
            }
          },
          child: Icon(
            _step > 1
                ? Icons.arrow_back_ios_new_rounded
                : Icons.close_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Create Trip',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      );

  Widget _buildStep() => switch (_step) {
        1 => _buildRolesStep(),
        2 => _buildRouteStep(),
        3 => _buildDateStep(),
        _ => _buildReviewStep(),
      };

  // ── Step 1: Role selection ──────────────────────────────────────────────────

  Widget _buildRolesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who do you need?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select one or more crew roles for this trip.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ..._roles.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoleCard(
                icon: r.icon,
                title: r.title,
                description: r.desc,
                selected: _selectedRoles.contains(r.title),
                onTap: () => setState(() {
                  if (_selectedRoles.contains(r.title)) {
                    _selectedRoles.remove(r.title);
                  } else {
                    _selectedRoles.add(r.title);
                  }
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedRoles.isEmpty)
            Text(
              'Select at least one role to continue.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFFB33A3A)),
            ),
        ],
      ),
    );
  }

  // ── Step 2: Route ──────────────────────────────────────────────────────────

  Widget _buildRouteStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you flying?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter ICAO or IATA airport codes.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'Origin Airport',
            controller: _fromCtrl,
            hint: 'e.g. KTEB or TEB',
            errorText: _fromError,
            prefixIcon: const Icon(Icons.flight_takeoff_rounded,
                color: Colors.white38, size: 18),
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) => setState(() => _fromError = null),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _gold.withValues(alpha: 0.3), width: 1),
              ),
              child: const Icon(Icons.swap_vert_rounded,
                  color: _gold, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Destination Airport',
            controller: _toCtrl,
            hint: 'e.g. KMIA or MIA',
            errorText: _toError,
            prefixIcon: const Icon(Icons.flight_land_rounded,
                color: Colors.white38, size: 18),
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) => setState(() => _toError = null),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isRoundTrip = !_isRoundTrip),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _isRoundTrip ? _gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isRoundTrip ? _gold : const Color(0xFF555555),
                      width: 1.5,
                    ),
                  ),
                  child: _isRoundTrip
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Color(0xFF0C0A08))
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Round trip',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Notes (optional)',
            controller: _notesCtrl,
            hint: 'Special instructions, requirements…',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ── Step 3: Date ───────────────────────────────────────────────────────────

  Widget _buildDateStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When is the flight?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set departure and optional return date.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          _datePickerTile(
            label: 'Departure Date',
            value: _departDate,
            icon: Icons.flight_takeoff_rounded,
            onTap: () => _pickDate(isDeparture: true),
          ),
          if (_dateError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: Color(0xFFB33A3A)),
                const SizedBox(width: 4),
                Text(
                  _dateError!,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFFB33A3A)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (_isRoundTrip)
            _datePickerTile(
              label: 'Return Date',
              value: _returnDate,
              icon: Icons.flight_land_rounded,
              onTap: () => _pickDate(isDeparture: false),
            ),
          const SizedBox(height: 24),
          _quickDateChips(),
        ],
      ),
    );
  }

  Widget _datePickerTile({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? _gold.withValues(alpha: 0.5) : const Color(0xFF2A2520),
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasValue ? _gold : Colors.white38, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: hasValue ? _gold : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasValue
                        ? '${value.day} ${_monthName(value.month)} ${value.year}'
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: hasValue ? Colors.white : Colors.white38,
                      fontWeight: hasValue
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                color: hasValue ? _gold : Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _quickDateChips() {
    final now = DateTime.now();
    final options = [
      ('Today', now),
      ('Tomorrow', now.add(const Duration(days: 1))),
      ('Next week', now.add(const Duration(days: 7))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK SELECT',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((o) {
            final selected = _departDate?.day == o.$2.day &&
                _departDate?.month == o.$2.month;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _departDate = o.$2;
                  _dateError = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? _gold : const Color(0xFF1E1A14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? _gold : const Color(0xFF2A2520),
                    ),
                  ),
                  child: Text(
                    o.$1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: selected
                          ? const Color(0xFF0C0A08)
                          : Colors.white70,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Step 4: Review ──────────────────────────────────────────────────────────

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Post',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirm your trip details before posting.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          _reviewSection('Crew Needed', _selectedRoles.join(', ')),
          const SizedBox(height: 12),
          _reviewSection(
            'Route',
            '${_fromCtrl.text.toUpperCase()} → ${_toCtrl.text.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          _reviewSection(
            'Departure',
            _departDate != null
                ? '${_departDate!.day} ${_monthName(_departDate!.month)} ${_departDate!.year}'
                : '—',
          ),
          if (_isRoundTrip && _returnDate != null) ...[
            const SizedBox(height: 12),
            _reviewSection(
              'Return',
              '${_returnDate!.day} ${_monthName(_returnDate!.month)} ${_returnDate!.year}',
            ),
          ],
          if (_notesCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _reviewSection('Notes', _notesCtrl.text),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _gold.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: _gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Matching crew will be notified and can apply to your trip.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewSection(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2520), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white38,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0A08),
        border: Border(top: BorderSide(color: Color(0xFF2A2520), width: 1)),
      ),
      child: AppButton(
        label: _step < _totalSteps ? 'Continue' : 'Post Trip',
        state: _canProceed ? _submitState : AppButtonState.disabled,
        onTap: _next,
        icon: _step == _totalSteps ? Icons.send_rounded : null,
        width: double.infinity,
        height: 52,
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? (_departDate ?? now)
          : (_returnDate ?? (_departDate ?? now).add(const Duration(days: 1))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            surface: Color(0xFF181410),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isDeparture) {
        _departDate = picked;
        _dateError = null;
      } else {
        _returnDate = picked;
      }
    });
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}
