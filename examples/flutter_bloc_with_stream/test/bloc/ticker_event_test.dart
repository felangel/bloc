import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerEvent', () {
    group('TickerStarted', () {
      test('supports value comparison', () {
        expect(TickerStarted(), TickerStarted());
      });
    });

    group('TickerTicked', () {
      test('supports value comparison', () {
        expect(const TickerTicked(1), const TickerTicked(1));
        expect(const TickerTicked(1), isNot(equals(const TickerTicked(2))));
      });
    });
  });
}
