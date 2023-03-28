import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/product_list/product_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

class ShoppingTab extends StatelessWidget {
  const ShoppingTab({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const AnalyticRouteSettings(
        screenView: ScreenView(routeName: 'shopping_tab'),
      ),
      builder: (_) => BlocProvider(
        create: (context) => ProductListBloc(
          context.read<ShoppingRepository>(),
        )..add(
            const ProductListStarted(),
          ),
        child: const ShoppingTab(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Shopping'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ProductList(),
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final allProducts = context.select(
      (ProductListBloc bloc) => bloc.state.allProducts,
    );

    final status = context.select(
      (ProductListBloc bloc) => bloc.state.status,
    );

    if (status == ProductListStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }
    if (status == ProductListStatus.failure) {
      return const Center(
        child: Text('Something went wrong.'),
      );
    }
    if (allProducts.isEmpty) {
      return const Center(
        child: Text('No products available!'),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        if (index >= allProducts.length) return null;
        return ProductItem(allProducts[index]);
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isAdded = context.select(
      (ProductListBloc bloc) => bloc.state.selectedProducts.contains(product),
    );

    final isPending = context.select(
      (ProductListBloc bloc) => bloc.state.pendingProduct == product,
    );

    return ListTile(
      onTap: () {
        if (isPending) return;
        context.read<ProductListBloc>().add(
              isAdded
                  ? ProductListProductRemoved(product)
                  : ProductListProductAdded(product),
            );
      },
      title: Text(product.name),
      subtitle: Text('\$${product.price}'),
      leading: InfoButton(product: product),
      trailing: isAdded
          ? const Icon(
              Icons.check,
              color: Colors.green,
            )
          : const Icon(
              Icons.add,
              color: Colors.black87,
            ),
    );
  }
}

class InfoButton extends StatelessWidget {
  const InfoButton({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          ProductInfoPage.route(product),
        );
      },
      icon: const Icon(
        Icons.info,
        color: Colors.black54,
      ),
    );
  }
}
