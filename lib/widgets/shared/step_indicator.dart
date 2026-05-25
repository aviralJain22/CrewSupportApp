import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
  });

  final int totalSteps;
  final int currentStep; // 1-based
  final List<String>? labels;

  static const _gold = Color(0xFFD4AF37);
  static const _inactive = Color(0xFF2A2520);
  static const _done = Color(0xFF8A6E20);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) return _connector(i ~/ 2 + 1);
            final step = i ~/ 2 + 1;
            return _stepDot(step);
          }),
        ),
        if (labels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalSteps, (i) {
              final step = i + 1;
              final active = step == currentStep;
              final done = step < currentStep;
              return Expanded(
                child: Text(
                  labels![i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? _gold
                        : done
                            ? _done
                            : Colors.white38,
                    letterSpacing: 0.3,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _stepDot(int step) {
    final active = step == currentStep;
    final done = step < currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 32 : 24,
      height: active ? 32 : 24,
      decoration: BoxDecoration(
        color: done
            ? _done
            : active
                ? _gold
                : _inactive,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? _gold : done ? _done : const Color(0xFF3A3530),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded,
                size: 13, color: Colors.white)
            : Text(
                '$step',
                style: GoogleFonts.inter(
                  fontSize: active ? 13 : 11,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? const Color(0xFF0C0A08)
                      : Colors.white38,
                ),
              ),
      ),
    );
  }

  Widget _connector(int afterStep) {
    final done = afterStep < currentStep;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 2,
        decoration: BoxDecoration(
          gradient: done
              ? const LinearGradient(colors: [_done, _done])
              : LinearGradient(
                  colors: [
                    const Color(0xFF2A2520),
                    const Color(0xFF2A2520).withValues(alpha: 0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
