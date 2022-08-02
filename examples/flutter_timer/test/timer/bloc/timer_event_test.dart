// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/timer/timer.dart';

void main() {
  group('TimerEvent', () {
    group('TimerStarted', () {
      test('supports value comparison', () {
        expect(
          TimerStarted(duration: 60),
          TimerStarted(duration: 60),
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
          TimerTicked(duration: 60),
          TimerTicked(duration: 60),
        );
      });
    });
  });
}
