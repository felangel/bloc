// ignore_for_file: prefer_const_constructors

import 'package:analytics_repository/analytics_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:shopping_repository/shopping_repository.dart';

import '../../../helpers/helpers.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  group('CheckoutDialog', () {
    late MockNavigator navigator;
    late CartBloc cartBloc;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});
      cartBloc = MockCartBloc();
      when(() => cartBloc.state).thenReturn(CartState());
    });

    testWidgets('renders CheckoutDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cartBloc,
            child: Container(),
          ),
        ),
      );
      final context = tester.element(find.byType(Container));

      await tester.pumpRoute(CheckoutDialog.route(context));
      expect(find.byType(CheckoutDialog), findsOneWidget);
    });

    testWidgets('pops when return button is pressed', (tester) async {
      await tester.pumpApp(
        MockNavigatorProvider(
          navigator: navigator,
          child: CheckoutDialog(),
        ),
      );

      await tester.tap(find.text('Return'));

      verify(() => navigator.pop<Object?>()).called(1);
    });
  });
}
