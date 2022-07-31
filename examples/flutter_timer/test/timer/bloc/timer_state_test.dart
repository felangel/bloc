// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/timer/timer.dart';

void main() {
  group('TimerState', () {
    group('TimerInitial', () {
      test('supports value comparison', () {
        expect(
          TimerInitial(60),
          TimerInitial(60),
        );
      });
    });
    group('TimerRunPause', () {
      test('supports value comparison', () {
        expect(
          TimerRunPause(60),
          TimerRunPause(60),
        );
      });
    });
    group('TimerRunInProgress', () {
      test('supports value comparison', () {
        expect(
          TimerRunInProgress(60),
          TimerRunInProgress(60),
        );
      });
    });
    group('TimerRunComplete', () {
      test('supports value comparison', () {
        expect(
          TimerRunComplete(),
          TimerRunComplete(),
        );
      });
    });
  });
}
