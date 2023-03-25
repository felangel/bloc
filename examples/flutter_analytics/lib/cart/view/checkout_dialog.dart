import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutDialog extends StatelessWidget {
  const CheckoutDialog({super.key});

  static DialogRoute<void> route(BuildContext context) {
    final cart = context.read<CartBloc>().state;

    return DialogRoute<void>(
      context: context,
      settings: AnalyticRouteSettings(
        screenView: ScreenView(
          routeName: 'checkout_dialog',
          parameters: {
            'total': cart.totalPrice,
          },
        ),
      ),
      builder: (context) => const CheckoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: const Text('This has not been implemented yet.'),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Return'),
        ),
      ],
    );
  }
}
