import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';

class MyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ColoredBox(
        color: Colors.yellow,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            const Divider(height: 4, color: Colors.black),
            _CartTotal()
          ],
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const CircularProgressIndicator();
        }
        if (state is CartLoaded) {
          return ListView.builder(
            itemCount: state.cart.items.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.done),
              title: Text(
                state.cart.items[index].name,
                style: itemNameStyle,
              ),
            ),
          );
        }
        return const Text('Something went wrong!');
      },
    );
  }
}

class _CartTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hugeStyle =
        Theme.of(context).textTheme.headline1.copyWith(fontSize: 48);

    return SizedBox(
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<CartBloc, CartState>(builder: (context, state) {
              if (state is CartLoading) {
                return const CircularProgressIndicator();
              }
              if (state is CartLoaded) {
                return Text('\$${state.cart.totalPrice}', style: hugeStyle);
              }
              return const Text('Something went wrong!');
            }),
            const SizedBox(width: 24),
            FlatButton(
              onPressed: () {
                Scaffold.of(context).showSnackBar(
                  const SnackBar(content: Text('Buying not supported yet.')),
                );
              },
              color: Colors.white,
              child: const Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}
