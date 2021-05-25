import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Repository', () {
    late Repository repository;

    setUp(() {
      repository = Repository();
    });

    group('fetchItems', () {
      test('returns list of items', () {
        final items = List<Item>.generate(
          10,
          (index) => Item(id: '$index', value: 'Item $index'),
        );
        expect(
          repository.fetchItems(),
          completion(equals(items)),
        );
      });
    });

    group('deleteItem', () {
      test('return null when deleting item', () {
        expect(
          repository.deleteItem('2'),
          completion(equals(null)),
        );
      });
    });
  });
}
