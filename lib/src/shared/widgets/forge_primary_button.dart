import 'package:flutter/material.dart';

class ForgePrimaryButton extends StatelessWidget {
  const ForgePrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.play_arrow_rounded),
      label: Text(label),
    );
  }
}
