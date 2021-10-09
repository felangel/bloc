import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class MockCatalogBloc extends MockBloc<CatalogEvent, CatalogState>
    implements CatalogBloc {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp({
    CartBloc? cartBloc,
    CatalogBloc? catalogBloc,
    required Widget child,
  }) {
    return pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            cartBloc != null
                ? BlocProvider.value(value: cartBloc)
                : BlocProvider(create: (_) => MockCartBloc()),
            catalogBloc != null
                ? BlocProvider.value(value: catalogBloc)
                : BlocProvider(create: (_) => MockCatalogBloc()),
          ],
          child: child,
        ),
      ),
    );
  }
}
