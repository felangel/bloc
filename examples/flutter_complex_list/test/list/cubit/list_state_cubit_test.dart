import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_complex_list/list/cubit/list_cubit.dart';
import 'package:flutter_complex_list/list/list.dart';
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

  group('ListCubit', () {
    late Repository repository;

    setUp(() {
      repository = MockRepository();
    });

    test('initial state is ListState.loading', () {
      expect(
        ListCubit(repository: repository).state,
        const ListState.loading(),
      );
    });

    blocTest<ListCubit, ListState>(
      'emits ListState.success after fetching list',
      build: () {
        when(repository.fetchItems).thenAnswer((_) async => mockItems);
        return ListCubit(repository: repository);
      },
      act: (cubit) => cubit.fetchList(),
      expect: () => [
        const ListState.success(mockItems),
      ],
      verify: (_) => verify(repository.fetchItems).called(1),
    );

    blocTest<ListCubit, ListState>(
      'emits ListState.failure after failing to fetch list',
      build: () {
        when(repository.fetchItems).thenThrow(Exception('Error'));
        return ListCubit(repository: repository);
      },
      act: (cubit) => cubit.fetchList(),
      expect: () => [
        const ListState.failure(),
      ],
      verify: (_) => verify(repository.fetchItems).called(1),
    );

    blocTest<ListCubit, ListState>(
      'emits corrects states when deleting an item',
      build: () {
        when(() => repository.deleteItem('2')).thenAnswer((_) async => null);
        return ListCubit(repository: repository);
      },
      seed: () => const ListState.success(mockItems),
      act: (cubit) => cubit.deleteItem('2'),
      expect: () => [
        const ListState.success([
          Item(id: '1', value: '1', isDeleting: false),
          Item(id: '2', value: '2', isDeleting: true),
          Item(id: '3', value: '3', isDeleting: false),
        ]),
        const ListState.success([
          Item(id: '1', value: '1', isDeleting: false),
          Item(id: '3', value: '3', isDeleting: false),
        ]),
      ],
      verify: (_) => verify(() => repository.deleteItem('2')).called(1),
    );
  });
}
