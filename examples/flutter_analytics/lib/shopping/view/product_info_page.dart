import 'package:flutter/material.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({super.key});

  static Route<void> route(BuildContext context) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'product_info'),
      builder: (context) => const ProductInfoPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Info'),
      ),
      body: const Text('Hi'),
    );
  }
}
