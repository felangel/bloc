import 'package:flutter_timer/bloc/timer_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimerEvent', () {
    group('TimerStarted', () {
      test('supports value comparison', () {
        expect(
          const TimerStarted(duration: 60),
          const TimerStarted(duration: 60),
        );
      });
    });
    group('TimerPaused', () {
      test('supports value comparison', () {
        expect(TimerPaused(), TimerPaused());
      });
    });
    group('TimerResumed', () {
      test('supports value comparison', () {
        expect(TimerResumed(), TimerResumed());
      });
    });
    group('TimerReset', () {
      test('supports value comparison', () {
        expect(TimerReset(), TimerReset());
      });
    });
    group('TimerTicked', () {
      test('supports value comparison', () {
        expect(
          const TimerTicked(duration: 60),
          const TimerTicked(duration: 60),
        );
      });
    });
  });
}
