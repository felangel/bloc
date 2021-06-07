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
        expect(const TickerTickSuccess(1), const TickerTickSuccess(1));
        expect(
          const TickerTickSuccess(1),
          isNot(equals(const TickerTickSuccess(2))),
        );
      });
    });
  });
}
