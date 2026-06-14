import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';
import '../../../core/if_spacing.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_progress_ring.dart';
import '../../../shared/widgets/forge_shell.dart';

class RestTimerScreen extends StatefulWidget {
  const RestTimerScreen({super.key});

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen> {
  static const initialSeconds = 150;
  Timer? timer;
  int remaining = initialSeconds;
  bool running = true;
  bool vibration = true;
  String sound = 'Beep';

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _start() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!running) return;
      if (remaining <= 1) {
        timer?.cancel();
        if (vibration) HapticFeedback.heavyImpact();
        if (sound != 'Off') SystemSound.play(SystemSoundType.alert);
        setState(() => remaining = 0);
      } else {
        setState(() => remaining -= 1);
      }
    });
  }

  String get label =>
      '${(remaining ~/ 60).toString().padLeft(1, '0')}:${(remaining % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final percent = (remaining / initialSeconds).clamp(0.0, 1.0);

    return ForgeShell(
      title: 'Rest Timer',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          ForgeCard(
            glow: true,
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
            child: Column(
              children: [
                ForgeProgressRing(
                  size: 280,
                  strokeWidth: 14,
                  value: percent,
                  backgroundColor: IFColors.panel3,
                  color: IFColors.red,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('RESTING', style: IFText.micro),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: IFColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        running ? 'counting down' : 'paused',
                        style: IFText.bodyMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: IFSpacing.spacingBlock),
                Row(
                  children: [
                    Expanded(
                      child: _TimerControlButton(
                        label: '-15s',
                        onTap: () => setState(
                          () => remaining = (remaining - 15).clamp(0, 999),
                        ),
                      ),
                    ),
                    const SizedBox(width: IFSpacing.spacingBlock),
                    Expanded(
                      child: _TimerControlButton(
                        label: running ? 'PAUSE' : 'START',
                        icon: running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        primary: true,
                        onTap: () => setState(() => running = !running),
                      ),
                    ),
                    const SizedBox(width: IFSpacing.spacingBlock),
                    Expanded(
                      child: _TimerControlButton(
                        label: '+15s',
                        onTap: () => setState(() => remaining += 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          ForgeCard(
            padding: const EdgeInsets.all(IFSpacing.paddingCard),
            child: Column(
              children: [
                _TimerSettingRow(
                  icon: Icons.vibration_rounded,
                  label: 'Vibration',
                  value: vibration ? 'ON' : 'OFF',
                  active: vibration,
                  onTap: () => setState(() => vibration = !vibration),
                ),
                const Divider(height: 16),
                _SoundSettingRow(
                  sound: sound,
                  onChanged: (value) => setState(() => sound = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: IFSpacing.spacingBlock),
          ForgeCard(
            padding: const EdgeInsets.all(IFSpacing.paddingCard),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: IFColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                    border:
                        Border.all(color: IFColors.red.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.timer_outlined, color: IFColors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOCAL TIMER', style: IFText.micro),
                      SizedBox(height: 3),
                      Text('No background notifications enabled.',
                          style: IFText.bodyMuted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerControlButton extends StatelessWidget {
  const _TimerControlButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? Colors.white : IFColors.text;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: primary ? IFColors.red : IFColors.panel2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: primary
                  ? IFColors.redGlow.withValues(alpha: 0.34)
                  : IFColors.border),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: IFColors.red.withValues(alpha: 0.22),
                    blurRadius: 20,
                    spreadRadius: -12,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foreground, size: 19),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSettingRow extends StatelessWidget {
  const _TimerSettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: active ? IFColors.red : IFColors.textMuted),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: IFText.cardTitle)),
            Text(
              value,
              style: TextStyle(
                color: active ? IFColors.red : IFColors.textFaint,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundSettingRow extends StatelessWidget {
  const _SoundSettingRow({required this.sound, required this.onChanged});

  final String sound;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_up_rounded, color: IFColors.red),
        const SizedBox(width: 12),
        const Expanded(child: Text('Sound', style: IFText.cardTitle)),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: sound,
            dropdownColor: IFColors.panel2,
            items: const ['Beep', 'Chime', 'Off']
                .map((item) => DropdownMenuItem(
                    value: item, child: Text(item.toUpperCase())))
                .toList(),
            onChanged: (value) => onChanged(value ?? sound),
          ),
        ),
      ],
    );
  }
}
