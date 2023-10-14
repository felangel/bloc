import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  group('CartBloc', () {
    final mockItems = [
      Item(1, 'item #1'),
      Item(2, 'item #2'),
      Item(3, 'item #3'),
    ];

    final mockItemToAdd = Item(4, 'item #4');
    final mockItemToRemove = Item(2, 'item #2');

    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
    });

    test('initial state is CartLoading', () {
      expect(
        CartBloc(shoppingRepository: shoppingRepository).state,
        CartLoading(),
      );
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when cart is loaded successfully',
      setUp: () {
        when(shoppingRepository.loadCartItems).thenAnswer((_) async => []);
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      act: (bloc) => bloc.add(CartStarted()),
      expect: () => <CartState>[CartLoading(), const CartLoaded()],
      verify: (_) => verify(shoppingRepository.loadCartItems).called(1),
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when loading the cart throws an error',
      setUp: () {
        when(shoppingRepository.loadCartItems).thenThrow(Exception('Error'));
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      act: (bloc) => bloc..add(CartStarted()),
      expect: () => <CartState>[CartLoading(), CartError()],
      verify: (_) => verify(shoppingRepository.loadCartItems).called(1),
    );

    blocTest<CartBloc, CartState>(
      'emits [] when cart is not finished loading and item is added',
      setUp: () {
        when(
          () => shoppingRepository.addItemToCart(mockItemToAdd),
        ).thenAnswer((_) async {});
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
      expect: () => <CartState>[],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] when item is added successfully',
      setUp: () {
        when(
          () => shoppingRepository.addItemToCart(mockItemToAdd),
        ).thenAnswer((_) async {});
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      seed: () => CartLoaded(cart: Cart(items: mockItems)),
      act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
      expect: () => <CartState>[
        CartLoaded(cart: Cart(items: [...mockItems, mockItemToAdd])),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addItemToCart(mockItemToAdd)).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [CartError] when item is not added successfully',
      setUp: () {
        when(
          () => shoppingRepository.addItemToCart(mockItemToAdd),
        ).thenThrow(Exception('Error'));
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      seed: () => CartLoaded(cart: Cart(items: mockItems)),
      act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
      expect: () => <CartState>[CartError()],
      verify: (_) {
        verify(
          () => shoppingRepository.addItemToCart(mockItemToAdd),
        ).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] when item is removed successfully',
      setUp: () {
        when(
          () => shoppingRepository.removeItemFromCart(mockItemToRemove),
        ).thenAnswer((_) async {});
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      seed: () => CartLoaded(cart: Cart(items: mockItems)),
      act: (bloc) => bloc.add(CartItemRemoved(mockItemToRemove)),
      expect: () => <CartState>[
        CartLoaded(cart: Cart(items: [...mockItems]..remove(mockItemToRemove))),
      ],
      verify: (_) {
        verify(
          () => shoppingRepository.removeItemFromCart(mockItemToRemove),
        ).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [CartError] when item is not removed successfully',
      setUp: () {
        when(
          () => shoppingRepository.removeItemFromCart(mockItemToRemove),
        ).thenThrow(Exception('Error'));
      },
      build: () => CartBloc(shoppingRepository: shoppingRepository),
      seed: () => CartLoaded(cart: Cart(items: mockItems)),
      act: (bloc) => bloc.add(CartItemRemoved(mockItemToRemove)),
      expect: () => <CartState>[CartError()],
      verify: (_) {
        verify(
          () => shoppingRepository.removeItemFromCart(mockItemToRemove),
        ).called(1);
      },
    );
  });
}
