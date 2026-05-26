import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  static const _bg     = Color(0xFF0A0905);
  static const _card   = Color(0xFF141210);
  static const _gold   = Color(0xFFD4AF37);
  static const _border = Color(0xFF2A2520);
  static const _iconBg = Color(0xFF1E1A12);

  final _tripNameCtrl = TextEditingController();
  final _enrouteCtrl  = TextEditingController();

  String?   _departureCode;
  String?   _destinationCode;
  DateTime? _startDate;
  DateTime? _endDate;
  String?   _radius;
  String?   _aircraftType;
  bool      _isLoading = false;

  static const _airportCodes = [
    'KTEB', 'KMIA', 'KLAX', 'KJFK', 'KORD', 'KSFO', 'KDFW',
    'KLAS', 'KBOS', 'KDCA', 'KSNA', 'KPBI', 'KDEN', 'KIAH',
    'EGLL', 'LFPG', 'LEBL', 'OMDB', 'VHHH', 'RJTT',
  ];

  static const _radiusOptions = [
    'Any Distance', 'Within 25 mi', 'Within 50 mi',
    'Within 100 mi', 'Within 200 mi',
  ];

  static const _aircraftOptions = [
    'Heavy Jet', 'Midsize Jet', 'Light Jet', 'Turboprop', 'Airliner / VIP',
  ];

  @override
  void dispose() {
    _tripNameCtrl.dispose();
    _enrouteCtrl.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _tripNameCtrl.text.isNotEmpty ||
      _enrouteCtrl.text.isNotEmpty ||
      _departureCode != null ||
      _destinationCode != null ||
      _startDate != null ||
      _endDate != null ||
      _radius != null ||
      _aircraftType != null;

  bool get _canProceed =>
      _tripNameCtrl.text.trim().isNotEmpty &&
      _departureCode != null &&
      _destinationCode != null &&
      _startDate != null &&
      _endDate != null;

  void _handleBack() {
    if (_isDirty) {
      _showDiscardDialog();
    } else {
      Get.back();
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _DiscardDialog(
        onExit: () {
          Navigator.of(context).pop(); // close dialog
          Get.back();                  // leave screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showDiscardDialog();
      },
      child: Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildTopBar()),
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildFields()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
            _buildNextBtn(),
          ],
        ),
      ),
    ),   // Scaffold
    );   // PopScope
  }

  // ── Top bar ──────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: _handleBack,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _card,
            border: Border.all(color: _gold.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.18),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _gold, size: 16),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Trip',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in the details below to plan\nyour journey.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white38,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            height: 64,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(96, 64),
                  painter: _TrailPainter(),
                ),
                Positioned(
                  right: 2,
                  top: 10,
                  child: Transform.rotate(
                    angle: -math.pi * 0.08,
                    child: const Icon(Icons.flight, color: _gold, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fields ───────────────────────────────────────────────────────────────────

  Widget _buildFields() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          _textRow(
            icon: Icons.description_outlined,
            label: 'Trip Name',
            ctrl: _tripNameCtrl,
            hint: 'Enter Trip Name',
          ),
          const SizedBox(height: 10),
          _dropdownRow(
            icon: Icons.flight_takeoff_rounded,
            label: 'Departure Airport Code',
            value: _departureCode,
            hint: 'Select Code',
            options: _airportCodes,
            onSelect: (v) => setState(() => _departureCode = v),
          ),
          const SizedBox(height: 10),
          _textRow(
            icon: Icons.alt_route_rounded,
            label: 'Enroute Airports',
            ctrl: _enrouteCtrl,
            hint: 'Enter Enroute Airport',
          ),
          const SizedBox(height: 10),
          _dropdownRow(
            icon: Icons.flight_land_rounded,
            label: 'Destination Airport Code',
            value: _destinationCode,
            hint: 'Select Code',
            options: _airportCodes,
            onSelect: (v) => setState(() => _destinationCode = v),
          ),
          const SizedBox(height: 10),
          _dateRow(
            icon: Icons.calendar_month_outlined,
            label: 'Start Date',
            value: _startDate,
            hint: 'Select Start Date',
            onTap: () => _pickDate(isStart: true),
          ),
          const SizedBox(height: 10),
          _dateRow(
            icon: Icons.event_outlined,
            label: 'End Date',
            value: _endDate,
            hint: 'Select End Date',
            onTap: () => _pickDate(isStart: false),
          ),
          const SizedBox(height: 10),
          _dropdownRow(
            icon: Icons.my_location_rounded,
            label: 'Departure Airport Radius',
            value: _radius,
            hint: 'Crew Proximity',
            options: _radiusOptions,
            onSelect: (v) => setState(() => _radius = v),
          ),
          const SizedBox(height: 10),
          _dropdownRow(
            icon: Icons.airplanemode_active_rounded,
            label: 'Aircraft Type',
            value: _aircraftType,
            hint: 'Select Aircraft',
            options: _aircraftOptions,
            onSelect: (v) => setState(() => _aircraftType = v),
          ),
        ],
      ),
    );
  }

  // ── Row widgets ──────────────────────────────────────────────────────────────

  Widget _rowShell({required Widget child}) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _iconBg,
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: _gold, size: 18),
    );
  }

  Widget _textRow({
    required IconData icon,
    required String label,
    required TextEditingController ctrl,
    required String hint,
  }) {
    return _rowShell(
      child: Row(
        children: [
          _iconCircle(icon),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              controller: ctrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              cursorColor: _gold,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    GoogleFonts.inter(fontSize: 13, color: Colors.white38),
                isDense: true,
                contentPadding: const EdgeInsets.only(right: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow({
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    return GestureDetector(
      onTap: () => _showPicker(label, options, onSelect),
      child: _rowShell(
        child: Row(
          children: [
            _iconCircle(icon),
            const SizedBox(width: 14),
            Expanded(
              flex: 5,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              flex: 4,
              child: Text(
                value ?? hint,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: value != null ? Colors.white70 : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: _gold.withValues(alpha: 0.75), size: 20),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _dateRow({
    required IconData icon,
    required String label,
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final display = value != null
        ? '${value.day} ${_monthName(value.month)} ${value.year}'
        : null;
    return GestureDetector(
      onTap: onTap,
      child: _rowShell(
        child: Row(
          children: [
            _iconCircle(icon),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              flex: 4,
              child: Text(
                display ?? hint,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: display != null ? Colors.white70 : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.calendar_today_outlined,
                color: _gold.withValues(alpha: 0.75), size: 17),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ── Next button ──────────────────────────────────────────────────────────────

  Widget _buildNextBtn() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: _canProceed && !_isLoading ? _submit : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            gradient: _canProceed
                ? const LinearGradient(
                    colors: [Color(0xFFE8C547), Color(0xFFD4AF37)],
                  )
                : null,
            color: _canProceed ? null : const Color(0xFF2A2520),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _canProceed
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: const Color(0xFF0A0905),
                    strokeWidth: 2,
                    backgroundColor: _gold.withValues(alpha: 0.2),
                  ),
                )
              else ...[
                Text(
                  'NEXT',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: _canProceed
                        ? const Color(0xFF0A0905)
                        : Colors.white24,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: _canProceed ? const Color(0xFF0A0905) : Colors.white24,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _showPicker(
      String title, List<String> options, ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181410),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
        title: title,
        options: options,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ??
            (_startDate ?? now).add(const Duration(days: 1)));
    final first = isStart ? now : (_startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
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
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Get.back();
    }
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ─── Picker sheet ─────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.onSelect,
  });

  final String title;
  final List<String> options;
  final ValueChanged<String> onSelect;

  static const _gold   = Color(0xFFD4AF37);
  static const _border = Color(0xFF2A2520);
  static const _card   = Color(0xFF181410);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 18),
            decoration: BoxDecoration(
              color: _border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              itemCount: options.length,
              itemBuilder: (_, i) {
                final opt = options[i];
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.white)),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white24, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plane trail painter ──────────────────────────────────────────────────────

class _TrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.25, size.height * 0.85,
        size.width * 0.55, size.height * 0.35,
        size.width * 0.82, size.height * 0.22,
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + 5), paint);
        dist += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Discard changes dialog ───────────────────────────────────────────────────

class _DiscardDialog extends StatelessWidget {
  const _DiscardDialog({required this.onExit});

  final VoidCallback onExit;

  static const _gold   = Color(0xFFD4AF37);
  static const _border = Color(0xFF2A2520);
  static const _card   = Color(0xFF1C1812);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.1),
                border: Border.all(color: _gold.withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: _gold, size: 26),
            ),
            const SizedBox(height: 18),
            // Title
            Text(
              'Discard changes?',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle
            Text(
              'You\'ll lose the trip details\nyou\'ve entered.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white38,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Exit
                Expanded(
                  child: GestureDetector(
                    onTap: onExit,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8C547), _gold],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Exit',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A0905),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
