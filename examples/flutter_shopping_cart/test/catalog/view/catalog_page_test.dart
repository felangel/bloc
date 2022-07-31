// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helper.dart';

void main() {
  late CartBloc cartBloc;
  late CatalogBloc catalogBloc;

  setUp(() {
    catalogBloc = MockCatalogBloc();
    cartBloc = MockCartBloc();
  });

  group('CatalogPage', () {
    testWidgets(
        'renders SliverFillRemaining with loading indicator '
        'when catalog is loading', (tester) async {
      when(() => catalogBloc.state).thenReturn(CatalogLoading());
      await tester.pumpApp(
        catalogBloc: catalogBloc,
        child: CatalogPage(),
      );
      expect(
        find.descendant(
          of: find.byType(SliverFillRemaining),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'renders SliverList with two items '
        'when catalog is loaded', (tester) async {
      final catalog = Catalog(itemNames: const ['item #1', 'item #2']);
      when(() => catalogBloc.state).thenReturn(CatalogLoaded(catalog));
      when(() => cartBloc.state).thenReturn(CartLoading());
      await tester.pumpApp(
        cartBloc: cartBloc,
        catalogBloc: catalogBloc,
        child: CatalogPage(),
      );

      expect(find.byType(SliverList), findsOneWidget);
      expect(find.byType(CatalogListItem), findsNWidgets(2));
    });

    testWidgets(
        'renders error text '
        'when catalog fails to load', (tester) async {
      when(() => catalogBloc.state).thenReturn(CatalogError());
      await tester.pumpApp(
        catalogBloc: catalogBloc,
        child: CatalogPage(),
      );

      expect(find.text('Something went wrong!'), findsOneWidget);
    });
  });

  group('AddButton', () {
    final mockItem = Item(1, 'item #1');
    testWidgets(
        'renders CircularProgressIndicator when '
        'cart is loading', (tester) async {
      when(() => cartBloc.state).thenReturn(CartLoading());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: AddButton(item: mockItem),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        "renders 'Add' text button "
        'when item is not in the cart', (tester) async {
      when(() => cartBloc.state).thenReturn(const CartLoaded());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: AddButton(item: mockItem),
      );
      expect(find.text('ADD'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets(
        'renders check icon '
        'when item is already added to cart', (tester) async {
      when(() => cartBloc.state).thenReturn(
        CartLoaded(cart: Cart(items: [mockItem])),
      );
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: AddButton(item: mockItem),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('ADD'), findsNothing);
    });

    testWidgets('adds item to the cart', (tester) async {
      when(() => cartBloc.state).thenReturn(const CartLoaded());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: AddButton(item: mockItem),
      );

      await tester.tap(find.text('ADD'));
      verify(() => cartBloc.add(CartItemAdded(mockItem))).called(1);
    });
  });
}
