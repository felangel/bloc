import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';

class App extends StatelessWidget {
  App({required this.shoppingRepository});

  final ShoppingRepository shoppingRepository;

  @override
  Widget build(BuildContext context) {
    final catalogBloc = CatalogBloc(shoppingRepository: shoppingRepository)
      ..add(CatalogStarted());

    final cartBloc = CartBloc(shoppingRepository: shoppingRepository)
      ..add(CartStarted());

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: catalogBloc,
        ),
        BlocProvider.value(
          value: cartBloc,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Bloc Shopping Cart',
        initialRoute: '/',
        routes: {
          '/': (context) => CatalogPage(),
          '/cart': (context) => CartPage(),
        },
      ),
    );
  }
}
