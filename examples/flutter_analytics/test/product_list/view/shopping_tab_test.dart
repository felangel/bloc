// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/product_list/product_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:shopping_repository/shopping_repository.dart';

import '../../helpers/helpers.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockProductListBloc extends MockBloc<ProductListEvent, ProductListState>
    implements ProductListBloc {}

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('CartTab', () {
    late ShoppingRepository shoppingRepository;
    late ProductListBloc productListBloc;
    late MockNavigator navigator;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      productListBloc = MockProductListBloc();
      when(() => shoppingRepository.selectedProducts).thenAnswer(
        (_) => Stream.empty(),
      );
      when(() => productListBloc.state).thenReturn(ProductListState());
      navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: productListBloc,
          child: const ShoppingTab(),
        ),
      );
    }

    group('route', () {
      testWidgets('renders ShoppingTab', (tester) async {
        await tester.pumpRoute(
          ShoppingTab.route(),
          shoppingRepository: shoppingRepository,
        );
        expect(find.byType(ShoppingTab), findsOneWidget);
      });
    });

    testWidgets('renders ProductItems when there are products', (tester) async {
      when(() => productListBloc.state).thenReturn(
        ProductListState(
          status: ProductListStatus.success,
          allProducts: const [product],
        ),
      );
      await tester.pumpApp(buildSubject());
      expect(find.byType(ProductItem), findsWidgets);
    });

    testWidgets('adds ProductListProductAdded when product is tapped',
        (tester) async {
      when(() => productListBloc.state).thenReturn(
        ProductListState(
          status: ProductListStatus.success,
          allProducts: const [product],
        ),
      );
      await tester.pumpApp(buildSubject());
      await tester.tap(find.byType(ProductItem));
      verify(() => productListBloc.add(ProductListProductAdded(product)))
          .called(1);
    });

    testWidgets(
        'adds ProductListProductRemoved when a selected product is tapped',
        (tester) async {
      when(() => productListBloc.state).thenReturn(
        ProductListState(
          status: ProductListStatus.success,
          allProducts: const [product],
          selectedProducts: const [product],
        ),
      );
      await tester.pumpApp(buildSubject());
      await tester.tap(find.byType(ProductItem));
      verify(() => productListBloc.add(ProductListProductRemoved(product)))
          .called(1);
    });

    testWidgets('navigates when InfoButton is pressed', (tester) async {
      when(() => productListBloc.state).thenReturn(
        ProductListState(
          status: ProductListStatus.success,
          allProducts: const [product],
        ),
      );

      await tester.pumpApp(
        MockNavigatorProvider(
          navigator: navigator,
          child: buildSubject(),
        ),
      );
      await tester.tap(find.byType(InfoButton));
      verify(() => navigator.push<void>(any())).called(1);
    });
  });
}
