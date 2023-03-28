import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/view/cart_tab.dart';
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_analytics/product_list/view/view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_repository/shopping_repository.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  group('App', () {
    late ShoppingRepository shoppingRepository;
    late AnalyticsRepository analyticsRepository;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      when(shoppingRepository.fetchCartProducts).thenAnswer(
        (_) => Future.value([]),
      );
      when(shoppingRepository.fetchAllOffers).thenAnswer(
        (_) => Future.value([]),
      );
      when(shoppingRepository.fetchAllProducts).thenAnswer(
        (_) => Future.value([]),
      );
      when(() => shoppingRepository.selectedProducts)
          .thenAnswer((_) => const Stream.empty());
      analyticsRepository = MockAnalyticsRepository();
    });

    testWidgets('renders TabRootPage', (tester) async {
      await tester.pumpWidget(
        App(
          shoppingRepository: shoppingRepository,
          analyticsRepository: analyticsRepository,
        ),
      );
      expect(find.byType(TabRootPage), findsOneWidget);
    });

    testWidgets('can switch between tabs', (tester) async {
      await tester.pumpWidget(
        App(
          shoppingRepository: shoppingRepository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.tap(find.byIcon(Icons.sell));
      await tester.pumpAndSettle();
      expect(find.byType(OfferTab), findsOneWidget);

      await tester.tap(find.byIcon(Icons.shopping_bag));
      await tester.pumpAndSettle();
      expect(find.byType(ShoppingTab), findsOneWidget);

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      expect(find.byType(CartTab), findsOneWidget);
    });
  });
}
