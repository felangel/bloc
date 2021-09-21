// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerEvent', () {
    group('TickerStarted', () {
      test('supports value comparison', () {
        expect(TickerStarted(), equals(TickerStarted()));
      });
    });
  });
}
