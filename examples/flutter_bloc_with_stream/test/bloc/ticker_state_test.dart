// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerState', () {
    group('TickerInitial', () {
      test('supports value comparison', () {
        expect(TickerInitial(), TickerInitial());
      });
    });

    group('TickerTickSuccess', () {
      test('supports value comparison', () {
        expect(TickerTickSuccess(1), TickerTickSuccess(1));
        expect(
          TickerTickSuccess(1),
          isNot(equals(TickerTickSuccess(2))),
        );
      });
    });

    group('TickerComplete', () {
      test('supports value comparison', () {
        expect(TickerComplete(), equals(TickerComplete()));
      });
    });
  });
}
