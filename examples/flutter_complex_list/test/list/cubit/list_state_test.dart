// ignore_for_file: prefer_const_constructors
import 'package:flutter_complex_list/list/list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListState', () {
    final mockItems = [const Item(id: '1', value: '1')];
    test('support value comparisons', () {
      expect(ListState.loading(), ListState.loading());
      expect(ListState.success(mockItems), ListState.success(mockItems));
      expect(ListState.failure(), ListState.failure());
    });
  });
}
