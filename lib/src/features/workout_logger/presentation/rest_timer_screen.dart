import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 18),
          Center(
            child: ForgeProgressRing(
              size: 256,
              strokeWidth: 14,
              value: percent,
              backgroundColor: IFColors.panel3,
              color: IFColors.red,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('RESTING', style: IFText.micro),
                  const SizedBox(height: 8),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('UP NEXT', style: IFText.micro),
                  const Text('Bench Press • Set 3 of 4',
                      style: IFText.bodyMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(
                          () => remaining = (remaining - 15).clamp(0, 999)),
                      child: const Text('-15s'))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () => setState(() => running = !running),
                      child: Icon(running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded))),
              const SizedBox(width: 12),
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(() => remaining += 15),
                      child: const Text('+15s'))),
            ],
          ),
          const SizedBox(height: 16),
          ForgeCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibration'),
                  value: vibration,
                  onChanged: (value) => setState(() => vibration = value),
                ),
                DropdownButtonFormField<String>(
                  initialValue: sound,
                  decoration: const InputDecoration(labelText: 'Sound'),
                  items: const ['Beep', 'Chime', 'Off']
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => sound = value ?? sound),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
