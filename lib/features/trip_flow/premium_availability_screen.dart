import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/section_header.dart';

class _AvailSlot {
  final String id;
  final DateTime start;
  final DateTime end;
  final String location;
  final bool isCurrent;

  const _AvailSlot({
    required this.id,
    required this.start,
    required this.end,
    required this.location,
    required this.isCurrent,
  });
}

class PremiumAvailabilityScreen extends StatefulWidget {
  const PremiumAvailabilityScreen({super.key});

  @override
  State<PremiumAvailabilityScreen> createState() =>
      _PremiumAvailabilityScreenState();
}

class _PremiumAvailabilityScreenState
    extends State<PremiumAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);

  late final TabController _tabCtrl;
  bool _showForm = false;

  // form fields
  DateTime? _formStart;
  DateTime? _formEnd;
  final _locationCtrl = TextEditingController();
  String? _startError, _endError, _locationError;
  _AvailSlot? _editingSlot;

  final List<_AvailSlot> _slots = [
    _AvailSlot(
      id: '1',
      start: DateTime.now().subtract(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 1)),
      location: 'KTEB — Teterboro, NJ',
      isCurrent: true,
    ),
    _AvailSlot(
      id: '2',
      start: DateTime.now().add(const Duration(days: 5)),
      end: DateTime.now().add(const Duration(days: 10)),
      location: 'KMIA — Miami, FL',
      isCurrent: false,
    ),
    _AvailSlot(
      id: '3',
      start: DateTime.now().add(const Duration(days: 14)),
      end: DateTime.now().add(const Duration(days: 18)),
      location: 'KSFO — San Francisco, CA',
      isCurrent: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  List<_AvailSlot> get _current =>
      _slots.where((s) => s.isCurrent).toList();
  List<_AvailSlot> get _future =>
      _slots.where((s) => !s.isCurrent).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar,
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_current, isCurrent: true),
                _buildList(_future, isCurrent: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_showForm ? _fab : null,
      bottomSheet: _showForm ? _buildForm() : null,
    );
  }

  AppBar get _appBar => AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(
          'Availability',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      );

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2520), width: 1),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: const Color(0xFF0C0A08),
        unselectedLabelColor: Colors.white54,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Current'),
          Tab(text: 'Future'),
        ],
      ),
    );
  }

  Widget _buildList(List<_AvailSlot> slots, {required bool isCurrent}) {
    if (slots.isEmpty) {
      return EmptyState(
        icon: isCurrent
            ? Icons.event_available_rounded
            : Icons.event_note_rounded,
        title: isCurrent ? 'No current availability' : 'No future slots',
        subtitle: isCurrent
            ? 'Add your current available dates to get matched with trips.'
            : 'Schedule your upcoming availability windows here.',
        ctaLabel: 'Add Availability',
        onCta: _openForm,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: slots.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SectionHeader(
              title: '${slots.length} slot${slots.length == 1 ? '' : 's'}',
              actionLabel: 'Add new',
              onAction: _openForm,
            ),
          );
        }
        return _buildSlotCard(slots[i - 1]);
      },
    );
  }

  Widget _buildSlotCard(_AvailSlot slot) {
    return Dismissible(
      key: Key(slot.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFB33A3A), size: 22),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFFB33A3A)),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(slot),
      onDismissed: (_) => setState(() => _slots.remove(slot)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: slot.isCurrent
                ? const Color(0xFF3DAA57).withValues(alpha: 0.4)
                : const Color(0xFF2A2520),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: slot.isCurrent
                    ? const Color(0xFF3DAA57).withValues(alpha: 0.12)
                    : _gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                slot.isCurrent
                    ? Icons.event_available_rounded
                    : Icons.event_note_rounded,
                color:
                    slot.isCurrent ? const Color(0xFF3DAA57) : _gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt(slot.start)} – ${_fmt(slot.end)}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.white38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.location,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _durationChip(slot),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _openForm(slot: slot),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2520),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.white54, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationChip(_AvailSlot slot) {
    final days = slot.end.difference(slot.start).inDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2520),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$days day${days == 1 ? '' : 's'}',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Add / Edit form ────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF181410),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
            top: BorderSide(
                color: Color(0xFF2A2520), width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _editingSlot == null ? 'ADD AVAILABILITY' : 'EDIT SLOT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                    letterSpacing: 1.8,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _closeForm,
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _formDateTile(
              label: 'Start Date',
              value: _formStart,
              error: _startError,
              onTap: () => _pickFormDate(isStart: true),
            ),
            const SizedBox(height: 12),
            _formDateTile(
              label: 'End Date',
              value: _formEnd,
              error: _endError,
              onTap: () => _pickFormDate(isStart: false),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Base Location',
              controller: _locationCtrl,
              hint: 'e.g. KTEB — Teterboro, NJ',
              errorText: _locationError,
              prefixIcon: const Icon(Icons.location_on_outlined,
                  color: Colors.white38, size: 18),
              onChanged: (v) => setState(() => _locationError = null),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _editingSlot == null ? 'Save Availability' : 'Update',
              onTap: _saveSlot,
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _formDateTile({
    required String label,
    required DateTime? value,
    required String? error,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1612),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFB33A3A)
                    : hasValue
                        ? _gold.withValues(alpha: 0.5)
                        : const Color(0xFF2E2A22),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16,
                    color: hasValue ? _gold : Colors.white38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: hasValue ? _gold : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasValue ? _fmt(value) : 'Tap to select',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: hasValue ? Colors.white : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 13, color: Color(0xFFB33A3A)),
              const SizedBox(width: 4),
              Text(
                error,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFFB33A3A)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _openForm({_AvailSlot? slot}) {
    setState(() {
      _editingSlot = slot;
      _formStart = slot?.start;
      _formEnd = slot?.end;
      _locationCtrl.text = slot?.location ?? '';
      _startError = null;
      _endError = null;
      _locationError = null;
      _showForm = true;
    });
  }

  void _closeForm() => setState(() {
        _showForm = false;
        _editingSlot = null;
      });

  void _saveSlot() {
    bool valid = true;
    setState(() {
      _startError = _formStart == null ? 'Start date is required' : null;
      _endError = _formEnd == null ? 'End date is required' : null;
      _locationError =
          _locationCtrl.text.trim().isEmpty ? 'Location is required' : null;
      if (_startError != null || _endError != null || _locationError != null) {
        valid = false;
      }
    });
    if (!valid) return;

    final now = DateTime.now();
    final isCurrent =
        _formStart!.isBefore(now) || _formStart!.day == now.day;

    setState(() {
      if (_editingSlot != null) {
        final idx = _slots.indexWhere((s) => s.id == _editingSlot!.id);
        if (idx != -1) {
          _slots[idx] = _AvailSlot(
            id: _editingSlot!.id,
            start: _formStart!,
            end: _formEnd!,
            location: _locationCtrl.text.trim(),
            isCurrent: isCurrent,
          );
        }
      } else {
        _slots.add(_AvailSlot(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          start: _formStart!,
          end: _formEnd!,
          location: _locationCtrl.text.trim(),
          isCurrent: isCurrent,
        ));
      }
      _showForm = false;
      _editingSlot = null;
    });
  }

  Future<bool> _confirmDelete(_AvailSlot slot) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF181410),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2A2520), width: 1),
            ),
            title: Text(
              'Delete slot?',
              style: GoogleFonts.playfairDisplay(color: Colors.white),
            ),
            content: Text(
              'This availability window will be permanently removed.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style:
                        GoogleFonts.inter(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: GoogleFonts.inter(
                        color: const Color(0xFFB33A3A),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickFormDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_formStart ?? now)
          : (_formEnd ??
              (_formStart ?? now).add(const Duration(days: 1))),
      firstDate: now.subtract(const Duration(days: 30)),
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
        _formStart = picked;
        _startError = null;
      } else {
        _formEnd = picked;
        _endError = null;
      }
    });
  }

  Widget get _fab => GestureDetector(
        onTap: _openForm,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8C547), _gold],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded,
              color: Color(0xFF0C0A08), size: 28),
        ),
      );

  String _fmt(DateTime d) =>
      '${d.day} ${const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month]} ${d.year}';
}
