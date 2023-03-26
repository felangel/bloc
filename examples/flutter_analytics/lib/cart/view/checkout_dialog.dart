import 'package:flutter/material.dart';
import 'package:flutter_analytics/cart/bloc/cart_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutDialog extends StatelessWidget {
  const CheckoutDialog({super.key});

  static DialogRoute<void> route(BuildContext context) {
    return DialogRoute<void>(
      context: context,
      settings: const RouteSettings(name: 'checkout_dialog'),
      builder: (context) => const CheckoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          previous.isCheckout && !current.isCheckout,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: AlertDialog(
        title: const Text('Checkout'),
        content: const Text('This has not been implemented yet.'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(
                    const CartCheckoutCanceled(),
                  );
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }
}
