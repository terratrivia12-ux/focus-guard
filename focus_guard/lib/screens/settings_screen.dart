import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pomodoro_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroService>(
      builder: (context, pomo, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF07070F),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your focus sessions.',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 32),

                  _SectionTitle('Pomodoro Timer'),
                  const SizedBox(height: 16),

                  _DurationSetting(
                    label: 'Focus Duration',
                    subtitle: 'How long each focus session lasts',
                    value: pomo.focusDuration,
                    min: 5,
                    max: 90,
                    color: const Color(0xFFFF6B35),
                    onChanged: (v) => pomo.updateSettings(focus: v),
                  ),
                  const SizedBox(height: 14),
                  _DurationSetting(
                    label: 'Short Break',
                    subtitle: 'Rest between focus sessions',
                    value: pomo.shortBreakDuration,
                    min: 1,
                    max: 30,
                    color: const Color(0xFF00D4FF),
                    onChanged: (v) => pomo.updateSettings(shortBreak: v),
                  ),
                  const SizedBox(height: 14),
                  _DurationSetting(
                    label: 'Long Break',
                    subtitle: 'Longer rest after multiple sessions',
                    value: pomo.longBreakDuration,
                    min: 5,
                    max: 60,
                    color: const Color(0xFF7B61FF),
                    onChanged: (v) => pomo.updateSettings(longBreak: v),
                  ),
                  const SizedBox(height: 14),
                  _DurationSetting(
                    label: 'Sessions Before Long Break',
                    subtitle: 'Number of focus sessions before a long break',
                    value: pomo.sessionsBeforeLongBreak,
                    min: 2,
                    max: 8,
                    color: const Color(0xFFFF9A3C),
                    unit: '',
                    onChanged: (v) => pomo.updateSettings(sessionsBeforeLong: v),
                  ),
                  const SizedBox(height: 28),

                  _SectionTitle('Behavior'),
                  const SizedBox(height: 16),

                  _ToggleSetting(
                    label: 'Auto-start Next Session',
                    subtitle: 'Automatically begin the next session when one ends',
                    value: pomo.autoStartNext,
                    color: const Color(0xFFFF6B35),
                    onChanged: (v) => pomo.updateSettings(autoStart: v),
                  ),
                  const SizedBox(height: 28),

                  _SectionTitle('Permissions'),
                  const SizedBox(height: 16),
                  _PermissionCard(),
                  const SizedBox(height: 28),

                  _AboutCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFF6B35),
        letterSpacing: 2,
      ),
    );
  }
}

class _DurationSetting extends StatelessWidget {
  final String label;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final Color color;
  final String unit;
  final Function(int) onChanged;

  const _DurationSetting({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
    this.unit = 'min',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unit.isEmpty ? '$value' : '$value $unit',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white12,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final Color color;
  final Function(bool) onChanged;

  const _ToggleSetting({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            trackColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.selected)
                  ? color.withOpacity(0.3)
                  : Colors.white12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, color: Color(0xFF00D4FF), size: 20),
              const SizedBox(width: 10),
              Text(
                'Required Permissions',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To block apps, FocusGuard needs:\n\n'
            '• Accessibility Service — to detect and overlay blocked apps\n'
            '• Usage Stats — to monitor which apps are in use\n'
            '• Display Over Apps — to show the block screen\n\n'
            'Grant these in Android Settings → Apps → Special App Access.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFF7B61FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FocusGuard',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Version 1.0.0 · Built with Flutter',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
