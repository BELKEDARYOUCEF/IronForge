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
    final displayWeight = kg ? input : input;
    final totalLabel = '${displayWeight.g} ${kg ? 'kg' : 'lbs'}';

    return ForgeShell(
      title: 'Plate Calculator',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          ForgeCard(
            glow: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('KG')),
                          ButtonSegment(value: false, label: Text('LBS')),
                        ],
                        selected: {kg},
                        onSelectionChanged: (value) =>
                            setState(() => kg = value.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 20),
                  decoration: const InputDecoration(labelText: 'Total Weight'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const Text('TOTAL WEIGHT', style: IFText.micro),
                const SizedBox(height: 6),
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: IFColors.red,
                  ),
                ),
                const SizedBox(height: 20),
                _BarbellVisual(plates: plates),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('PLATES PER SIDE', style: IFText.label),
          const SizedBox(height: 8),
          ForgeCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (plates.isEmpty)
                  const _PlateCountRow(
                    label: 'No plates',
                    value: 'Bar only',
                    color: IFColors.textFaint,
                  ),
                for (final entry in _plateCounts(plates).entries) ...[
                  _PlateCountRow(
                    label: '${entry.key.g} kg',
                    value: '${entry.value * 2} plates',
                    color: _plateColor(entry.key),
                  ),
                  const Divider(height: 14),
                ],
                const _PlateCountRow(
                  label: 'Bar',
                  value: '20 kg',
                  color: IFColors.border,
                ),
                const Divider(height: 14),
                _PlateCountRow(
                  label: 'TOTAL',
                  value: '${targetKg.g} kg',
                  color: IFColors.red,
                  emphasize: true,
                ),
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

  Color _plateColor(double plate) {
    if (plate >= 25) return IFColors.red;
    if (plate >= 20) return IFColors.blue;
    if (plate >= 15) return IFColors.gold;
    if (plate >= 10) return IFColors.green;
    return IFColors.textFaint;
  }
}

class _BarbellVisual extends StatelessWidget {
  const _BarbellVisual({required this.plates});

  final List<double> plates;

  @override
  Widget build(BuildContext context) {
    final visible = plates.take(6).toList();

    return SizedBox(
      height: 102,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: IFColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final plate in visible.reversed)
                _PlateBlock(
                  label: plate.g,
                  color: _plateColor(plate),
                  height: _plateHeight(plate),
                ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: IFColors.panel3,
                  shape: BoxShape.circle,
                  border: Border.all(color: IFColors.border),
                ),
              ),
              for (final plate in visible)
                _PlateBlock(
                  label: plate.g,
                  color: _plateColor(plate),
                  height: _plateHeight(plate),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _plateColor(double plate) {
    if (plate >= 25) return IFColors.red;
    if (plate >= 20) return IFColors.blue;
    if (plate >= 15) return IFColors.gold;
    if (plate >= 10) return IFColors.green;
    return IFColors.textFaint;
  }

  static double _plateHeight(double plate) {
    if (plate >= 25) return 88;
    if (plate >= 20) return 80;
    if (plate >= 15) return 72;
    if (plate >= 10) return 62;
    if (plate >= 5) return 52;
    return 42;
  }
}

class _PlateBlock extends StatelessWidget {
  const _PlateBlock({
    required this.label,
    required this.color,
    required this.height,
  });

  final String label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }
}

class _PlateCountRow extends StatelessWidget {
  const _PlateCountRow({
    required this.label,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textColor = emphasize ? IFColors.red : IFColors.text;

    return Row(
      children: [
        Container(
          width: 12,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

extension _WeightFormat on num {
  String get g => this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2);
}
