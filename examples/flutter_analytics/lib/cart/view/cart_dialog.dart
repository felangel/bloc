import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';

class CartDialog extends StatelessWidget {
  const CartDialog({super.key});

  static DialogRoute<void> route(BuildContext context) {
    return DialogRoute<void>(
      context: context,
      settings: const RouteSettings(
        arguments: RouteAnalytic('alert_dialog_viewed'),
      ),
      builder: (context) => const CartDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
