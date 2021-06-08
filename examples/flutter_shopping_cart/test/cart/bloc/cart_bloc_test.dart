import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  group('CartBloc', () {
    late ShoppingRepository shoppingRepository;

    final mockItems = [
      Item(1, 'item #1'),
      Item(2, 'item #2'),
      Item(3, 'item #3'),
    ];

    final mockItemToAdd = Item(4, 'item #4');

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
        build: () {
          when(shoppingRepository.loadCart).thenAnswer((_) async => null);
          return CartBloc(shoppingRepository: shoppingRepository);
        },
        act: (bloc) => bloc.add(CartStarted()),
        expect: () => <CartState>[
              CartLoading(),
              const CartLoaded(),
            ],
        verify: (_) {
          return verify(shoppingRepository.loadCart).called(1);
        });

    blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartError] when loading the cart throws an error',
        build: () {
          when(shoppingRepository.loadCart).thenThrow(Exception('Error'));
          return CartBloc(shoppingRepository: shoppingRepository);
        },
        act: (bloc) => bloc..add(CartStarted()),
        expect: () => <CartState>[
              CartLoading(),
              CartError(),
            ],
        verify: (_) {
          return verify(shoppingRepository.loadCart).called(1);
        });

    blocTest<CartBloc, CartState>(
      'emits [] when cart is not finished loading and item is added',
      build: () {
        when(() => shoppingRepository.addItemToCart(mockItemToAdd))
            .thenAnswer((_) async => null);
        return CartBloc(shoppingRepository: shoppingRepository);
      },
      act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
      expect: () => <CartState>[],
    );

    blocTest<CartBloc, CartState>(
        'emits [CartLoaded] when item is added successfully',
        build: () {
          when(() => shoppingRepository.addItemToCart(mockItemToAdd))
              .thenAnswer((_) async => null);
          return CartBloc(shoppingRepository: shoppingRepository);
        },
        seed: () => CartLoaded(cart: Cart(items: mockItems)),
        act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
        expect: () => <CartState>[
              CartLoaded(cart: Cart(items: [...mockItems, mockItemToAdd]))
            ],
        verify: (_) {
          return verify(() => shoppingRepository.addItemToCart(mockItemToAdd))
              .called(1);
        });

    blocTest<CartBloc, CartState>(
        'emits [CartLoaded] when item is added successfully',
        build: () {
          when(() => shoppingRepository.addItemToCart(mockItemToAdd))
              .thenThrow(Exception('Error'));
          return CartBloc(shoppingRepository: shoppingRepository);
        },
        seed: () => CartLoaded(cart: Cart(items: mockItems)),
        act: (bloc) => bloc.add(CartItemAdded(mockItemToAdd)),
        expect: () => <CartState>[
              CartError(),
            ],
        verify: (_) {
          return verify(() => shoppingRepository.addItemToCart(mockItemToAdd))
              .called(1);
        });
  });
}
