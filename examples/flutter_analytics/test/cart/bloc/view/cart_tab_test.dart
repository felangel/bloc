// ignore_for_file: prefer_const_constructors

import 'package:analytics_repository/analytics_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:shopping_repository/shopping_repository.dart';

import '../../../helpers/helpers.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('CartTab', () {
    late ShoppingRepository shoppingRepository;
    late CartBloc cartBloc;
    late MockNavigator navigator;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      cartBloc = MockCartBloc();
      when(() => cartBloc.state).thenReturn(CartState());
      navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    });

    testWidgets('renders CartTab', (tester) async {
      await tester.pumpRoute(CartTab.route(), cartBloc: cartBloc);
      expect(find.byType(CartTab), findsOneWidget);
    });

    testWidgets('renders CartItems when there are products', (tester) async {
      when(() => cartBloc.state).thenReturn(
        CartState(
          products: const [product],
          status: CartStatus.success,
        ),
      );
      await tester.pumpRoute(CartTab.route(), cartBloc: cartBloc);
      expect(find.byType(CartItem), findsWidgets);
    });

    testWidgets('adds CartProductRemoved when product is long-pressed',
        (tester) async {
      when(() => cartBloc.state).thenReturn(
        CartState(
          status: CartStatus.success,
          products: const [product],
        ),
      );

      await tester.pumpRoute(
        CartTab.route(),
        shoppingRepository: shoppingRepository,
        cartBloc: cartBloc,
      );

      await tester.longPress(find.byType(CartItem));
      verify(() => cartBloc.add(CartProductRemoved(product))).called(1);
    });

    testWidgets('adds CartClearRequested when clear button is pressed',
        (tester) async {
      when(() => cartBloc.state).thenReturn(
        CartState(
          status: CartStatus.success,
          products: const [product],
        ),
      );

      await tester.pumpRoute(
        CartTab.route(),
        shoppingRepository: shoppingRepository,
        cartBloc: cartBloc,
      );

      await tester.tap(find.byType(ClearCartButton));
      verify(() => cartBloc.add(CartClearRequested())).called(1);
    });

    testWidgets('navigates when CheckoutButton is pressed', (tester) async {
      when(() => cartBloc.state).thenReturn(
        CartState(
          status: CartStatus.success,
          products: const [product],
        ),
      );

      await tester.pumpWidget(
        MockNavigatorProvider(
          navigator: navigator,
          child: tester.createSubject(
            cartBloc: cartBloc,
            child: CartTab(),
          ),
        ),
      );

      await tester.tap(find.byType(CheckoutButton));

      verify(() => navigator.push<void>(any())).called(1);
    });
  });
}
