// ignore_for_file: prefer_const_constructors
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComplexListState', () {
    const mockItems = [Item(id: '1', value: '1')];
    test('support value comparisons', () {
      expect(ComplexListState.loading(), ComplexListState.loading());
      expect(ComplexListState.failure(), ComplexListState.failure());
      expect(
        ComplexListState.success(mockItems),
        ComplexListState.success(mockItems),
      );
    });
  });
}
