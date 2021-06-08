import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  group('CatalogBloc', () {
    late ShoppingRepository shoppingRepository;

    final mockItemNames = ['Orange Juice', 'Milk', 'Macaroons', 'Cookies'];

    setUp(() {
      shoppingRepository = MockShoppingRepository();
    });

    test('initial state is CatalogLoading', () {
      expect(
        CatalogBloc(shoppingRepository: shoppingRepository).state,
        CatalogLoading(),
      );
    });

    blocTest<CatalogBloc, CatalogState>(
        'emits [CatalogLoading, CatalogLoaded] '
        'when catalog is loaded successfully',
        build: () {
          when(shoppingRepository.fetchCatalog)
              .thenAnswer((_) async => mockItemNames);
          return CatalogBloc(shoppingRepository: shoppingRepository);
        },
        act: (bloc) => bloc.add(CatalogStarted()),
        expect: () => <CatalogState>[
              CatalogLoading(),
              CatalogLoaded(Catalog(itemNames: mockItemNames))
            ],
        verify: (_) {
          return verify(shoppingRepository.fetchCatalog).called(1);
        });

    blocTest<CatalogBloc, CatalogState>(
        'emits [CatalogLoading, CatalogError] '
        'when loading the catalog throws an exception',
        build: () {
          when(shoppingRepository.fetchCatalog).thenThrow(Exception('Error'));
          return CatalogBloc(shoppingRepository: shoppingRepository);
        },
        act: (bloc) => bloc.add(CatalogStarted()),
        expect: () => <CatalogState>[
              CatalogLoading(),
              CatalogError(),
            ],
        verify: (_) {
          return verify(shoppingRepository.fetchCatalog).called(1);
        });
  });
}
