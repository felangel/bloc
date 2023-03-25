import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({super.key});

  static Route<void> route(BuildContext context) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(
        arguments: Analytic('product_info_page_viewed'),
      ),
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
