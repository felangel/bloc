// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_bloc_with_stream/ticker/ticker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicker extends Mock implements Ticker {}

void main() {
  group('TickerBloc', () {
    late Ticker ticker;

    setUp(() {
      ticker = MockTicker();
      when(ticker.tick).thenAnswer(
        (_) => Stream<int>.fromIterable([1, 2, 3]),
      );
    });

    test('initial state is TickerInitial', () {
      expect(TickerBloc(ticker).state, TickerInitial());
    });

    blocTest<TickerBloc, TickerState>(
      'emits [] when ticker has not started',
      build: () => TickerBloc(ticker),
      expect: () => <TickerState>[],
    );

    blocTest<TickerBloc, TickerState>(
      'emits TickerTickSuccess from 1 to 3',
      build: () => TickerBloc(ticker),
      act: (bloc) => bloc.add(TickerStarted()),
      expect: () => <TickerState>[
        TickerTickSuccess(1),
        TickerTickSuccess(2),
        TickerTickSuccess(3),
        TickerComplete(),
      ],
    );

    blocTest<TickerBloc, TickerState>(
      'emits TickerTickSuccess '
      'from 1 to 3 and cancels previous subscription',
      build: () => TickerBloc(ticker),
      act: (bloc) => bloc
        ..add(TickerStarted())
        ..add(TickerStarted()),
      expect: () => <TickerState>[
        TickerTickSuccess(1),
        TickerTickSuccess(2),
        TickerTickSuccess(3),
        TickerComplete(),
      ],
    );
  });
}
