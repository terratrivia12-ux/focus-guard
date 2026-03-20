import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pomodoro_service.dart';
import '../services/app_block_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PomodoroService, AppBlockService>(
      builder: (context, pomo, block, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF07070F),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Stats',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep pushing.',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Sessions',
                          value: '${pomo.completedSessions}',
                          icon: Icons.timer_rounded,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          label: 'Focus Time',
                          value: '${pomo.totalFocusMinutes ~/ 60}h ${pomo.totalFocusMinutes % 60}m',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFFF9A3C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Apps Blocked',
                          value: '${block.blockedCount}',
                          icon: Icons.shield_rounded,
                          color: const Color(0xFF00D4FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          label: 'Block Active',
                          value: block.isBlockingActive ? 'YES' : 'NO',
                          icon: block.isBlockingActive
                              ? Icons.lock_rounded
                              : Icons.lock_open_rounded,
                          color: block.isBlockingActive
                              ? const Color(0xFF00FF94)
                              : const Color(0xFF555577),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _ProgressSection(pomo: pomo),
                  const SizedBox(height: 28),
                  _MotivationCard(sessions: pomo.completedSessions),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final PomodoroService pomo;
  const _ProgressSection({required this.pomo});

  @override
  Widget build(BuildContext context) {
    final int goal = 8; // daily goal in sessions
    final double progress = (pomo.completedSessions / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${pomo.completedSessions} / $goal sessions',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B35)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress >= 1.0
                ? '🎉 Daily goal complete! Incredible work.'
                : '${(goal - pomo.completedSessions).clamp(0, goal)} sessions to reach your daily goal',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: progress >= 1.0
                  ? const Color(0xFF00FF94)
                  : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final int sessions;
  const _MotivationCard({required this.sessions});

  String get _quote {
    final quotes = [
      '"The secret of getting ahead is getting started." — Mark Twain',
      '"Focus is not about saying yes, it\'s about saying no." — Steve Jobs',
      '"Deep work is the ability to focus without distraction." — Cal Newport',
      '"Small disciplines repeated consistently lead to great achievements."',
      '"Every distraction you resist is a victory for your future self."',
    ];
    return quotes[sessions % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B61FF).withOpacity(0.15),
            const Color(0xFF00D4FF).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: Color(0xFF7B61FF), size: 20),
          const SizedBox(height: 10),
          Text(
            _quote,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
