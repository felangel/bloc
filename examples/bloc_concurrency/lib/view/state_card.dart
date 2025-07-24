import 'package:flutter/material.dart';

/// A widget that displays a card with a title and value, styled with a color.
class StateCard extends StatelessWidget {
  /// Creates an instance of [StateCard].
  const StateCard({
    required this.value,
    required this.title,
    required this.color,
    super.key,
  });

  /// The value to display in the card
  final String value;

  /// The title of the card
  final String title;

  /// The color associated with the card, used for UI representation
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
