import 'package:flutter/material.dart';

class ShoppingTab extends StatelessWidget {
  const ShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Placeholder(),
            settings: const RouteSettings(name: 'placeholder_page'),
          ),
        );
      },
      child: const Text('Push'),
    );
  }
}
