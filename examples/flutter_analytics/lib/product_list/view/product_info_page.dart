import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          routeName: 'product_info',
          parameters: {'product': product},
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
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
