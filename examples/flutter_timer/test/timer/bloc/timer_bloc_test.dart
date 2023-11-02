// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/timer.dart';
import 'package:mocktail/mocktail.dart';

class _MockTicker extends Mock implements Ticker {}

void main() {
  group('TimerBloc', () {
    late Ticker ticker;

    setUp(() {
      ticker = _MockTicker();
      when(() => ticker.tick(ticks: 5)).thenAnswer(
        (_) => Stream<int>.fromIterable([5, 4, 3, 2, 1]),
      );
    });

    test('initial state is TimerInitial(60)', () {
      expect(
        TimerBloc(ticker: ticker).state,
        TimerInitial(60),
      );
    });

    blocTest<TimerBloc, TimerState>(
      'emits TickerRunInProgress 5 times after timer started',
      build: () => TimerBloc(ticker: ticker),
      act: (bloc) => bloc.add(const TimerStarted(duration: 5)),
      expect: () => [
        TimerRunInProgress(5),
        TimerRunInProgress(4),
        TimerRunInProgress(3),
        TimerRunInProgress(2),
        TimerRunInProgress(1),
      ],
      verify: (_) => verify(() => ticker.tick(ticks: 5)).called(1),
    );

    blocTest<TimerBloc, TimerState>(
      'emits [TickerRunPause(2)] when ticker is paused at 2',
      build: () => TimerBloc(ticker: ticker),
      seed: () => TimerRunInProgress(2),
      act: (bloc) => bloc.add(TimerPaused()),
      expect: () => [TimerRunPause(2)],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [TickerRunInProgress(5)] when ticker is resumed at 5',
      build: () => TimerBloc(ticker: ticker),
      seed: () => TimerRunPause(5),
      act: (bloc) => bloc.add(TimerResumed()),
      expect: () => [TimerRunInProgress(5)],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [TickerInitial(60)] when timer is restarted',
      build: () => TimerBloc(ticker: ticker),
      act: (bloc) => bloc.add(TimerReset()),
      expect: () => [TimerInitial(60)],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [TimerRunInProgress(3)] when timer ticks to 3',
      setUp: () {
        when(() => ticker.tick(ticks: 3)).thenAnswer(
          (_) => Stream<int>.value(3),
        );
      },
      build: () => TimerBloc(ticker: ticker),
      act: (bloc) => bloc.add(TimerStarted(duration: 3)),
      expect: () => [TimerRunInProgress(3)],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [TimerRunInProgress(1), TimerRunComplete()] when timer ticks to 0',
      setUp: () {
        when(() => ticker.tick(ticks: 1)).thenAnswer(
          (_) => Stream<int>.fromIterable([1, 0]),
        );
      },
      build: () => TimerBloc(ticker: ticker),
      act: (bloc) => bloc.add(TimerStarted(duration: 1)),
      expect: () => [TimerRunInProgress(1), TimerRunComplete()],
    );
  });
}
