import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pomodoro_service.dart';
import '../services/app_block_service.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PomodoroService, AppBlockService>(
      builder: (context, pomo, block, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF07070F),
          body: SafeArea(
            child: Column(
              children: [
                _Header(pomo: pomo),
                const SizedBox(height: 24),
                _SessionDots(pomo: pomo),
                const SizedBox(height: 40),
                _TimerRing(pomo: pomo),
                const SizedBox(height: 40),
                _Controls(pomo: pomo, block: block),
                const Spacer(),
                _BlockStatus(block: block),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final PomodoroService pomo;
  const _Header({required this.pomo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FocusGuard',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Stay locked in.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: pomo.stateColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pomo.stateColor.withOpacity(0.3)),
            ),
            child: Text(
              pomo.stateLabel,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pomo.stateColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDots extends StatelessWidget {
  final PomodoroService pomo;
  const _SessionDots({required this.pomo});

  @override
  Widget build(BuildContext context) {
    final int total = pomo.sessionsBeforeLongBreak;
    final int done = pomo.completedSessions % total;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        bool filled = i < done;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: filled ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFFFF6B35) : Colors.white12,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _TimerRing extends StatelessWidget {
  final PomodoroService pomo;
  const _TimerRing({required this.pomo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: pomo.stateColor.withOpacity(0.15),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Progress ring
          CustomPaint(
            size: const Size(260, 260),
            painter: _RingPainter(
              progress: pomo.progress,
              color: pomo.stateColor,
            ),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pomo.timeDisplay,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pomo.completedSessions} sessions today',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi * progress,
        colors: [color.withOpacity(0.5), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // Dot at progress end
    if (progress > 0) {
      final angle = -pi / 2 + 2 * pi * progress;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _Controls extends StatelessWidget {
  final PomodoroService pomo;
  final AppBlockService block;
  const _Controls({required this.pomo, required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset
          _CircleBtn(
            icon: Icons.refresh_rounded,
            color: Colors.white24,
            size: 52,
            onTap: () {
              pomo.reset();
              if (block.isBlockingActive) block.stopBlocking();
            },
          ),
          const SizedBox(width: 24),
          // Play/Pause — big
          GestureDetector(
            onTap: () {
              if (pomo.state == PomodoroState.idle) {
                pomo.start();
                if (block.blockedCount > 0) {
                  block.startBlocking(pomo.focusDuration);
                }
              } else if (pomo.isRunning) {
                pomo.pause();
              } else {
                pomo.resume();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pomo.stateColor,
                boxShadow: [
                  BoxShadow(
                    color: pomo.stateColor.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                (pomo.state == PomodoroState.idle || pomo.isPaused)
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Skip
          _CircleBtn(
            icon: Icons.skip_next_rounded,
            color: Colors.white24,
            size: 52,
            onTap: pomo.skip,
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white54, size: size * 0.44),
      ),
    );
  }
}

class _BlockStatus extends StatelessWidget {
  final AppBlockService block;
  const _BlockStatus({required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: block.isBlockingActive
              ? const Color(0xFFFF6B35).withOpacity(0.1)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: block.isBlockingActive
                ? const Color(0xFFFF6B35).withOpacity(0.3)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              block.isBlockingActive
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              color: block.isBlockingActive
                  ? const Color(0xFFFF6B35)
                  : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                block.isBlockingActive
                    ? '${block.blockedCount} apps blocked · ${block.remainingBlockMinutes}m remaining'
                    : block.blockedCount > 0
                        ? '${block.blockedCount} apps ready to block'
                        : 'No apps selected to block',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: block.isBlockingActive
                      ? const Color(0xFFFF6B35)
                      : Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
