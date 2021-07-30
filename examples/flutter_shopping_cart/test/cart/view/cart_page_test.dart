import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helper.dart';

class FakeCartState extends Fake implements CartState {}

class FakeCartEvent extends Fake implements CartEvent {}

void main() {
  late CartBloc cartBloc;

  final mockItems = [
    Item(1, 'item #1'),
    Item(2, 'item #2'),
    Item(3, 'item #3'),
  ];

  final mockItemToRemove = mockItems.last;

  setUpAll(() {
    registerFallbackValue<CartState>(FakeCartState());
    registerFallbackValue<CartEvent>(FakeCartEvent());
  });

  setUp(() {
    cartBloc = MockCartBloc();
  });

  group('CartPage', () {
    testWidgets('renders CartList and CartTotal', (tester) async {
      when(() => cartBloc.state).thenReturn(CartLoading());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartPage(),
      );
      expect(find.byType(CartList), findsOneWidget);
      expect(find.byType(CartTotal), findsOneWidget);
    });
  });

  group('CartList', () {
    testWidgets(
        'renders CircularProgressIndicator '
        'when cart is loading', (tester) async {
      when(() => cartBloc.state).thenReturn(CartLoading());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartList(),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders 3 ListTile '
        'when cart is loaded with three items', (tester) async {
      when(() => cartBloc.state)
          .thenReturn(CartLoaded(cart: Cart(items: mockItems)));
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartList(),
      );
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets(
        'renders error text '
        'when cart fails to load', (tester) async {
      when(() => cartBloc.state).thenReturn(CartError());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartList(),
      );
      expect(find.text('Something went wrong!'), findsOneWidget);
    });
  });

  group('CartTotal', () {
    testWidgets(
        'renders CircularProgressIndicator '
        'when cart is loading', (tester) async {
      when(() => cartBloc.state).thenReturn(CartLoading());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartTotal(),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders total price '
        'when cart is loaded with three items', (tester) async {
      when(() => cartBloc.state)
          .thenReturn(CartLoaded(cart: Cart(items: mockItems)));
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartTotal(),
      );
      expect(find.text('\$${42 * 3}'), findsOneWidget);
    });

    testWidgets(
        'renders error text '
        'when cart fails to load', (tester) async {
      when(() => cartBloc.state).thenReturn(CartError());
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: CartTotal(),
      );
      expect(find.text('Something went wrong!'), findsOneWidget);
    });

    testWidgets(
        'removes item from cart items '
        'after long press', (tester) async {
      when(() => cartBloc.state)
          .thenReturn(CartLoaded(cart: Cart(items: mockItems)));
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: Scaffold(body: CartList()),
      );
      await tester.longPress(find.text(mockItemToRemove.name));
      await tester.pumpAndSettle();
      verify(() => cartBloc.add(CartItemRemoved(mockItemToRemove))).called(1);
    });

    testWidgets(
        'renders SnackBar after '
        'tapping the \'BUY\' button', (tester) async {
      when(() => cartBloc.state)
          .thenReturn(CartLoaded(cart: Cart(items: mockItems)));
      await tester.pumpApp(
        cartBloc: cartBloc,
        child: Scaffold(body: CartTotal()),
      );
      await tester.tap(find.text('BUY'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Buying not supported yet.'), findsOneWidget);
    });
  });
}
