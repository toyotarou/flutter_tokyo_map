import 'package:flutter/material.dart';

class CatButton extends StatelessWidget {
  const CatButton({required this.label, required this.selected, required this.onTap, super.key});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? Theme.of(context).colorScheme.primary : Colors.black54;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
