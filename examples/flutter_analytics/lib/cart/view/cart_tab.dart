import 'package:flutter/material.dart';
import 'package:flutter_analytics/cart/view/cart_dialog.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          CartDialog.route(context),
        );
      },
      child: const Text('Push'),
    );
  }
}
