import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'cart_page'),
      builder: (_) => const CartPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
        ),
        body: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              CartPage.route(),
            );
          },
          child: const Text('Push'),
        ));
  }
}
