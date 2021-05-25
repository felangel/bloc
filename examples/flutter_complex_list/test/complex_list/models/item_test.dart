import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Item', () {
    const mockItem = Item(id: '1', value: 'Item 1');
    test('support value comparisons', () {
      expect(mockItem, mockItem);
    });

    test('copyWith comparisons', () {
      expect(mockItem.copyWith(), mockItem);
      expect(
        mockItem.copyWith(id: '2', value: 'Item 2'),
        isNot(equals(mockItem)),
      );
    });
  });
}
