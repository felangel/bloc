import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const AnalyticRouteSettings(
        screenView: ScreenView(routeName: 'cart_tab'),
      ),
      builder: (_) => const CartTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Cart'),
        trailing: _ClearCartButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Cart(),
        ),
      ),
    );
  }
}

class _ClearCartButton extends StatelessWidget {
  const _ClearCartButton();

  @override
  Widget build(BuildContext context) {
    final isDisabled = context.select(
      (CartBloc bloc) =>
          bloc.state.status == CartStatus.loading ||
          bloc.state.products.isEmpty,
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isDisabled
          ? null
          : () {
              context.read<CartBloc>().add(
                    const CartClearRequested(),
                  );
            },
      child: Icon(
        Icons.delete,
        size: 24,
        color: isDisabled ? Colors.black26 : Colors.red,
      ),
    );
  }
}

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.select(
      (CartBloc bloc) => bloc.state.products,
    );

    if (products.isEmpty) {
      return const Center(
        child: Text('No products in cart.'),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CartProducts(),
        Column(
          children: const [
            _Total(),
            Divider(color: Colors.black26, height: 32),
            _CheckoutButton(),
          ],
        ),
      ],
    );
  }
}

class CartProducts extends StatelessWidget {
  const CartProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.select(
      (CartBloc bloc) => bloc.state.products,
    );

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index >= products.length) return null;
        return _CartItem(products[index]);
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        context.read<CartBloc>().add(
              CartProductRemoved(product),
            );
      },
      title: Text(product.name),
      trailing: Text('\$${product.price}'),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total();

  @override
  Widget build(BuildContext context) {
    final totalPrice = context.select(
      (CartBloc bloc) => bloc.state.totalPrice,
    );

    return Text(
      'Total: \$$totalPrice',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            color: Colors.blue,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                CheckoutDialog.route(context),
              );
            },
            child: const Text('Purchase'),
          ),
        ),
      ],
    );
  }
}
