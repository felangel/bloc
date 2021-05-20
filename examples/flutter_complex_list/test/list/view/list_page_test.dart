import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/list/list.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

class MockListCubit extends MockCubit<ListState> implements ListCubit {}

class FakeListState extends Fake implements ListState {}

extension on WidgetTester {
  Future<void> pumpListPage(ListCubit listCubit) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: listCubit, child: ListPage()),
      ),
    );
  }

  Future<void> pumpItemView(ListCubit listCubit, List<Item> items) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: listCubit,
          child: ItemView(items: items),
        ),
      ),
    );
  }

  Future<void> pumpItemTile(Item item) {
    return pumpWidget(MaterialApp(
      home: ItemTile(item: item, onDeletePressed: (id) {}),
    ));
  }
}

void main() {
  late ListCubit listCubit;
  const mockItems = [
    Item(id: '1', value: 'Item 1'),
    Item(id: '2', value: 'Item 2'),
    Item(id: '3', value: 'Item 3'),
  ];

  setUp(() {
    registerFallbackValue<ListState>(FakeListState());
    listCubit = MockListCubit();
  });

  group('ListPage', () {
    testWidgets(
        'renders CircularProgressIndicator while '
        'waiting for items to load', (tester) async {
      when(() => listCubit.state).thenReturn(const ListState.loading());
      await tester.pumpListPage(listCubit);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders error text '
        'when items fail to load', (tester) async {
      when(() => listCubit.state).thenReturn(const ListState.failure());
      await tester.pumpListPage(listCubit);
      expect(find.text('Oops something went wrong!'), findsOneWidget);
    });

    testWidgets(
        'renders ItemView after items '
        'are finished loading', (tester) async {
      when(() => listCubit.state)
          .thenReturn(const ListState.success(mockItems));
      await tester.pumpListPage(listCubit);
      expect(find.byType(ItemView), findsOneWidget);
    });
  });

  group('ItemView', () {
    testWidgets(
        'renders no content text when '
        'no items are present', (tester) async {
      when(() => listCubit.state).thenReturn(const ListState.success([]));
      await tester.pumpItemView(listCubit, []);
      expect(find.text('no content'), findsOneWidget);
    });

    testWidgets('renders three ItemTiles', (tester) async {
      when(() => listCubit.state)
          .thenReturn(const ListState.success(mockItems));
      await tester.pumpItemView(listCubit, mockItems);
      expect(find.byType(ItemTile), findsNWidgets(3));
    });

    testWidgets('deletes first item', (tester) async {
      when(() => listCubit.state)
          .thenReturn(const ListState.success(mockItems));
      when(() => listCubit.deleteItem('1')).thenAnswer((_) async => null);
      await tester.pumpItemView(listCubit, mockItems);
      await tester.tap(find.byIcon(Icons.delete).first);
      verify(() => listCubit.deleteItem('1')).called(1);
    });
  });

  group('ItemTile', () {
    testWidgets('renders id and value text', (tester) async {
      const mockItem = Item(id: '1', value: 'Item 1', isDeleting: false);
      await tester.pumpItemTile(mockItem);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets(
        'renders delete icon button'
        'when item is not being deleted', (tester) async {
      const mockItem = Item(id: '1', value: 'Item 1', isDeleting: false);
      await tester.pumpItemTile(mockItem);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets(
        'renders CircularProgressIndicator'
        'when item is being deleting', (tester) async {
      const mockItem = Item(id: '1', value: 'Item 1', isDeleting: true);
      await tester.pumpItemTile(mockItem);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
