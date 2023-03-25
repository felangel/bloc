import 'package:flutter/material.dart';

class CartDialog extends StatelessWidget {
  const CartDialog({super.key});

  static DialogRoute<void> route(BuildContext context) {
    return DialogRoute<void>(
      context: context,
      settings: const RouteSettings(name: 'alert_dialog'),
      builder: (context) => const CartDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            CartDialog.route(context),
          ),
          child: const Text('push'),
        ),
        ElevatedButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('pop'),
        ),
      ],
    );
  }
}
