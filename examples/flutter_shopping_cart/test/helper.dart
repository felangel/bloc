import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeCartState extends Fake implements CartState {}

class FakeCartEvent extends Fake implements CartEvent {}

class FakeCatalogState extends Fake implements CatalogState {}

class FakeCatalogEvent extends Fake implements CatalogEvent {}

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class MockCatalogBloc extends MockBloc<CatalogEvent, CatalogState>
    implements CatalogBloc {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp({
    CartBloc? cartBloc,
    CatalogBloc? catalogBloc,
    required Widget child,
  }) {
    registerFallbackValue<CartState>(FakeCartState());
    registerFallbackValue<CartEvent>(FakeCartEvent());
    registerFallbackValue<CatalogState>(FakeCatalogState());
    registerFallbackValue<CatalogEvent>(FakeCatalogEvent());

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
