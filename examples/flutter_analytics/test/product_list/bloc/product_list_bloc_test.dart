// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_analytics/product_list/product_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_repository/shopping_repository.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('ProductListBloc', () {
    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      when(() => shoppingRepository.selectedProducts).thenAnswer(
        (_) => Stream.empty(),
      );
    });

    test('initial state is CartLoading', () {
      expect(
        ProductListBloc(shoppingRepository).state,
        ProductListState(),
      );
    });

    blocTest<ProductListBloc, ProductListState>(
      'emits [success] when products are fetched successfully',
      setUp: () {
        when(shoppingRepository.fetchCartProducts).thenAnswer(
          (_) => Future.value([]),
        );
        when(shoppingRepository.fetchAllProducts).thenAnswer(
          (_) => Future.value([]),
        );
      },
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListStarted()),
      expect: () => [ProductListState(status: ProductListStatus.success)],
      verify: (_) => verify(shoppingRepository.fetchCartProducts).called(1),
    );

    blocTest<ProductListBloc, ProductListState>(
      'emits [failure] when fetching products fails',
      setUp: () {
        when(shoppingRepository.fetchAllProducts).thenThrow(
          Exception('oops'),
        );
      },
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListStarted()),
      expect: () => [ProductListState(status: ProductListStatus.failure)],
      verify: (_) => verify(shoppingRepository.fetchAllProducts).called(1),
    );

    blocTest<ProductListBloc, ProductListState>(
      'updates correctly when adding a product',
      setUp: () {
        when(
          () => shoppingRepository.addProductToCart(product),
        ).thenAnswer((_) => Future.value());
      },
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListProductAdded(product)),
      expect: () => [
        ProductListState(pendingProduct: product),
        ProductListState(selectedProducts: const [product]),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addProductToCart(product)).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'updates correctly when adding a product fails',
      setUp: () {
        when(
          () => shoppingRepository.addProductToCart(product),
        ).thenThrow(Exception('oops'));
      },
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListProductAdded(product)),
      expect: () => [
        ProductListState(pendingProduct: product),
        ProductListState(),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addProductToCart(product)).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'updates correctly when removing a product',
      setUp: () {
        when(
          () => shoppingRepository.removeProductFromCart(product),
        ).thenAnswer((_) => Future.value());
      },
      seed: () => ProductListState(selectedProducts: const [product]),
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListProductRemoved(product)),
      expect: () => [
        ProductListState(
          pendingProduct: product,
          selectedProducts: const [product],
        ),
        ProductListState(),
      ],
      verify: (_) {
        verify(() => shoppingRepository.removeProductFromCart(product))
            .called(1);
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'updates correctly when removing a product fails',
      setUp: () {
        when(
          () => shoppingRepository.removeProductFromCart(product),
        ).thenThrow(Exception('oops'));
      },
      build: () => ProductListBloc(shoppingRepository),
      act: (bloc) => bloc.add(ProductListProductRemoved(product)),
      expect: () => [
        ProductListState(pendingProduct: product),
        ProductListState(),
      ],
      verify: (_) {
        verify(() => shoppingRepository.removeProductFromCart(product))
            .called(1);
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'updates selected products when cart product stream changes',
      setUp: () {
        when(
          () => shoppingRepository.selectedProducts,
        ).thenAnswer(
          (_) => Stream.value(const [product, product]),
        );
      },
      seed: () => ProductListState(
        selectedProducts: const [product],
      ),
      build: () => ProductListBloc(shoppingRepository),
      expect: () => [
        ProductListState(
          selectedProducts: const [product, product],
        ),
      ],
    );
  });
}
