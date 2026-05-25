import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  static const _gold = Color(0xFFD4AF37);
  static const _border = Color(0xFF2A2520);
  static const _red = Color(0xFFB33A3A);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.isEmpty) {
      // Backspace: move focus back
      if (index > 0) {
        _controllers[index].clear();
        _nodes[index - 1].requestFocus();
      }
      widget.onChanged?.call(_currentValue);
      return;
    }

    // Accept only the last character if user pastes multiple
    final digit = value.characters.last;
    _controllers[index].text = digit;
    _controllers[index].selection =
        TextSelection.collapsed(offset: 1);

    widget.onChanged?.call(_currentValue);

    if (index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else {
      _nodes[index].unfocus();
      final full = _currentValue;
      if (full.length == widget.length) {
        widget.onCompleted?.call(full);
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _nodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged?.call(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        final isFilled = _controllers[i].text.isNotEmpty;
        return Padding(
          padding: EdgeInsets.only(right: i < widget.length - 1 ? 12 : 0),
          child: _OtpDigitBox(
            controller: _controllers[i],
            focusNode: _nodes[i],
            isFilled: isFilled,
            hasError: widget.hasError,
            onChanged: (v) => _onDigitEntered(i, v),
            onKeyEvent: (e) => _onKeyEvent(i, e),
            gold: _gold,
            border: _border,
            red: _red,
          ),
        );
      }),
    );
  }
}

class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.isFilled,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
    required this.gold,
    required this.border,
    required this.red,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFilled;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final Color gold;
  final Color border;
  final Color red;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? widget.red
        : _focused
            ? widget.gold
            : widget.isFilled
                ? widget.gold.withValues(alpha: 0.5)
                : widget.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: _focused || widget.hasError ? 1.5 : 1,
        ),
        boxShadow: _focused && !widget.hasError
            ? [
                BoxShadow(
                  color: widget.gold.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: widget.onKeyEvent,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: widget.hasError ? widget.red : Colors.white,
          ),
          cursorColor: widget.gold,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
