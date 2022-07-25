// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

void main() {
  group('CatalogBloc', () {
    const mockItemNames = ['Orange Juice', 'Milk', 'Macaroons', 'Cookies'];

    late ShoppingRepository shoppingRepository;

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
      setUp: () {
        when(shoppingRepository.loadCatalog).thenAnswer(
          (_) async => mockItemNames,
        );
      },
      build: () => CatalogBloc(shoppingRepository: shoppingRepository),
      act: (bloc) => bloc.add(CatalogStarted()),
      expect: () => <CatalogState>[
        CatalogLoading(),
        CatalogLoaded(Catalog(itemNames: mockItemNames)),
      ],
      verify: (_) => verify(shoppingRepository.loadCatalog).called(1),
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogError] '
      'when loading the catalog throws an exception',
      setUp: () {
        when(shoppingRepository.loadCatalog).thenThrow(Exception('Error'));
      },
      build: () => CatalogBloc(shoppingRepository: shoppingRepository),
      act: (bloc) => bloc.add(CatalogStarted()),
      expect: () => <CatalogState>[
        CatalogLoading(),
        CatalogError(),
      ],
      verify: (_) => verify(shoppingRepository.loadCatalog).called(1),
    );
  });
}
