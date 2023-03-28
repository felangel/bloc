// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_analytics/product_list/view/product_info_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:shopping_repository/shopping_repository.dart';

import '../../helpers/helpers.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('ProductInfoPage', () {
    late MockNavigator navigator;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    });

    testWidgets('renders ProductInfoPage', (tester) async {
      await tester.pumpRoute(ProductInfoPage.route(product));
      expect(find.byType(ProductInfoPage), findsOneWidget);
    });
  });
}
