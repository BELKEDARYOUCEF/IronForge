import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/if_text_styles.dart';
import '../../../shared/widgets/forge_card.dart';
import '../../../shared/widgets/forge_shell.dart';
import '../domain/workout_math.dart';

class PlateCalculatorScreen extends StatefulWidget {
  const PlateCalculatorScreen({super.key});

  @override
  State<PlateCalculatorScreen> createState() => _PlateCalculatorScreenState();
}

class _PlateCalculatorScreenState extends State<PlateCalculatorScreen> {
  final controller = TextEditingController(text: '102.5');
  final calculator = const PlateCalculator();
  bool kg = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = double.tryParse(controller.text) ?? 20;
    final targetKg = kg ? input : input / 2.2046226218;
    final plates = calculator.platesPerSide(targetKg);

    return ForgeShell(
      title: 'Plate Calculator',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: true, label: Text('KG')), ButtonSegment(value: false, label: Text('LBS'))],
            selected: {kg},
            onSelectionChanged: (value) => setState(() => kg = value.first),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total Weight'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          ForgeCard(
            glow: true,
            child: Column(
              children: [
                const Text('TOTAL', style: IFText.micro),
                const SizedBox(height: 6),
                Text('${input.toStringAsFixed(input % 1 == 0 ? 0 : 1)} ${kg ? 'kg' : 'lbs'}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: IFColors.red)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 76, height: 10, color: IFColors.border),
                    for (final plate in plates.take(5)) _PlateBlock(label: plate.toStringAsFixed(plate % 1 == 0 ? 0 : 2)),
                    Container(width: 76, height: 10, color: IFColors.border),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('PLATES PER SIDE', style: IFText.label),
          const SizedBox(height: 8),
          ForgeCard(
            child: Column(
              children: [
                for (final entry in _plateCounts(plates).entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${entry.key.g} kg'),
                    trailing: Text('${entry.value * 2} plates', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                const Divider(),
                const ListTile(contentPadding: EdgeInsets.zero, title: Text('Bar'), trailing: Text('20 kg', style: TextStyle(color: IFColors.red, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<double, int> _plateCounts(List<double> plates) {
    final counts = <double, int>{};
    for (final plate in plates) {
      counts[plate] = (counts[plate] ?? 0) + 1;
    }
    return counts;
  }
}

class _PlateBlock extends StatelessWidget {
  const _PlateBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: IFColors.redDark, borderRadius: BorderRadius.circular(5), border: Border.all(color: IFColors.red)),
      alignment: Alignment.center,
      child: RotatedBox(quarterTurns: 3, child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900))),
    );
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
