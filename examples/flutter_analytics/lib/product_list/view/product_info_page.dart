import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:shopping_repository/shopping_repository.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage(
    this.product, {
    super.key,
  });

  final Product product;

  static Route<void> route(Product product) {
    return MaterialPageRoute<void>(
      settings: AnalyticRouteSettings(
        screenView: ScreenView(
          routeName: 'product_info_page',
          parameters: {
            'product_id': product.id,
            'product_name': product.name,
            'product_price': product.price,
          },
        ),
      ),
      builder: (context) => ProductInfoPage(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(product.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(product.description),
            ],
          ),
        ),
      ),
    );
  }
}
