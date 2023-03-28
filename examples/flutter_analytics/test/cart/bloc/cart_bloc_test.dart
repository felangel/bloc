// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_analytics/cart/cart.dart';
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

  group('CartBloc', () {
    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      when(() => shoppingRepository.selectedProducts).thenAnswer(
        (_) => Stream.empty(),
      );
    });

    test('initial state is CartLoading', () {
      expect(
        CartBloc(shoppingRepository).state,
        CartState(),
      );
    });

    blocTest<CartBloc, CartState>(
      'emits [success] when products are fetched successfully',
      setUp: () {
        when(shoppingRepository.fetchCartProducts).thenAnswer(
          (_) => Future.value([]),
        );
      },
      build: () => CartBloc(shoppingRepository),
      act: (bloc) => bloc.add(CartStarted()),
      expect: () => [CartState(status: CartStatus.success)],
      verify: (_) => verify(shoppingRepository.fetchCartProducts).called(1),
    );

    blocTest<CartBloc, CartState>(
      'emits [failure] when fetching products fails',
      setUp: () {
        when(shoppingRepository.fetchCartProducts).thenThrow(
          Exception('oops'),
        );
      },
      build: () => CartBloc(shoppingRepository),
      act: (bloc) => bloc.add(CartStarted()),
      expect: () => [CartState(status: CartStatus.failure)],
      verify: (_) => verify(shoppingRepository.fetchCartProducts).called(1),
    );

    blocTest<CartBloc, CartState>(
      'updates correctly when adding a product',
      setUp: () {
        when(
          () => shoppingRepository.addProductToCart(product),
        ).thenAnswer((_) async {});
      },
      build: () => CartBloc(shoppingRepository),
      act: (bloc) => bloc.add(CartProductAdded(product)),
      expect: () => [
        CartState(pendingProduct: product),
        CartState(products: const [product]),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addProductToCart(product)).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'updates correctly when adding a product fails',
      setUp: () {
        when(
          () => shoppingRepository.addProductToCart(product),
        ).thenThrow(Exception('oops'));
      },
      build: () => CartBloc(shoppingRepository),
      act: (bloc) => bloc.add(CartProductAdded(product)),
      expect: () => [
        CartState(pendingProduct: product),
        CartState(),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addProductToCart(product)).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'updates correctly when removing a product',
      setUp: () {
        when(
          () => shoppingRepository.removeProductFromCart(product),
        ).thenAnswer((_) => Future.value());
      },
      build: () => CartBloc(shoppingRepository),
      seed: () => CartState(products: const [product]),
      act: (bloc) => bloc.add(CartProductRemoved(product)),
      expect: () => [
        CartState(
          products: const [product],
          pendingProduct: product,
        ),
        CartState(),
      ],
      verify: (_) {
        verify(() => shoppingRepository.removeProductFromCart(product))
            .called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'updates correctly when removing a product fails',
      setUp: () {
        when(
          () => shoppingRepository.removeProductFromCart(product),
        ).thenThrow(Exception('oops'));
      },
      build: () => CartBloc(shoppingRepository),
      seed: () => CartState(products: const [product]),
      act: (bloc) => bloc.add(CartProductRemoved(product)),
      expect: () => [
        CartState(
          products: const [product],
          pendingProduct: product,
        ),
        CartState(products: const [product]),
      ],
      verify: (_) {
        verify(() => shoppingRepository.removeProductFromCart(product))
            .called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [success] when clearing the cart is successful',
      setUp: () {
        when(
          () => shoppingRepository.clearCart(),
        ).thenAnswer((_) => Future.value());
      },
      build: () => CartBloc(shoppingRepository),
      seed: () => CartState(
        status: CartStatus.success,
        products: const [product],
      ),
      act: (bloc) => bloc.add(CartClearRequested()),
      expect: () => [
        CartState(products: const [product]),
        CartState(status: CartStatus.success),
      ],
      verify: (_) {
        verify(shoppingRepository.clearCart).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [failure] when clearing the cart fails',
      setUp: () {
        when(
          () => shoppingRepository.clearCart(),
        ).thenThrow(Exception('oops'));
      },
      build: () => CartBloc(shoppingRepository),
      seed: () => CartState(
        status: CartStatus.success,
        products: const [product],
      ),
      act: (bloc) => bloc.add(CartClearRequested()),
      expect: () => [
        CartState(products: const [product]),
        CartState(
          status: CartStatus.failure,
          products: const [product],
        ),
      ],
      verify: (_) {
        verify(shoppingRepository.clearCart).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'updates products when the selected product stream change',
      setUp: () {
        when(() => shoppingRepository.selectedProducts).thenAnswer(
          (_) => Stream.value([product]),
        );
      },
      build: () => CartBloc(shoppingRepository),
      expect: () => [
        CartState(products: const [product]),
      ],
    );
  });
}
