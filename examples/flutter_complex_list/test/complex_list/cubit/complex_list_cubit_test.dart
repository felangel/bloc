import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  const mockItems = [
    Item(id: '1', value: '1'),
    Item(id: '2', value: '2'),
    Item(id: '3', value: '3'),
  ];

  group('ComplexListCubit', () {
    late Repository repository;

    setUp(() {
      repository = MockRepository();
    });

    test('initial state is ComplexListState.loading', () {
      expect(
        ComplexListCubit(repository: repository).state,
        const ComplexListState.loading(),
      );
    });

    group('fetchList', () {
      blocTest<ComplexListCubit, ComplexListState>(
        'emits ComplexListState.success after fetching list',
        setUp: () {
          when(repository.fetchItems).thenAnswer((_) async => mockItems);
        },
        build: () => ComplexListCubit(repository: repository),
        act: (cubit) => cubit.fetchList(),
        expect: () => [
          const ComplexListState.success(mockItems),
        ],
        verify: (_) => verify(repository.fetchItems).called(1),
      );

      blocTest<ComplexListCubit, ComplexListState>(
        'emits ComplexListState.failure after failing to fetch list',
        setUp: () {
          when(repository.fetchItems).thenThrow(Exception('Error'));
        },
        build: () => ComplexListCubit(repository: repository),
        act: (cubit) => cubit.fetchList(),
        expect: () => [
          const ComplexListState.failure(),
        ],
        verify: (_) => verify(repository.fetchItems).called(1),
      );
    });

    group('deleteItem', () {
      blocTest<ComplexListCubit, ComplexListState>(
        'emits corrects states when deleting an item',
        setUp: () {
          when(() => repository.deleteItem('2')).thenAnswer((_) async {});
        },
        build: () => ComplexListCubit(repository: repository),
        seed: () => const ComplexListState.success(mockItems),
        act: (cubit) => cubit.deleteItem('2'),
        expect: () => [
          const ComplexListState.success([
            Item(id: '1', value: '1'),
            Item(id: '2', value: '2', isDeleting: true),
            Item(id: '3', value: '3'),
          ]),
          const ComplexListState.success([
            Item(id: '1', value: '1'),
            Item(id: '3', value: '3'),
          ]),
        ],
        verify: (_) => verify(() => repository.deleteItem('2')).called(1),
      );
    });
  });
}
