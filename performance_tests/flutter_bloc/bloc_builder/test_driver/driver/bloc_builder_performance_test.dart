import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

import 'package:flutter_test/flutter_test.dart' hide find;

void main() {
  final List<double> avgFrameResults = [];
  final List<double> worstFrameResults = [];
  FlutterDriver driver;

  double average(List<double> results) {
    double total = 0;
    results.forEach((frame) {
      total += frame;
    });
    return total / results.length;
  }

  Future<TimelineSummary> runTest() async {
    Timeline timeline = await driver.traceAction(() async {
      await driver.waitFor(find.text('0'));
      for (var i = 0; i < 10; i++) {
        await driver.tap(find.byValueKey('counter_increment'));
      }
      for (var i = 0; i < 10; i++) {
        await driver.tap(find.byValueKey('counter_decrement'));
      }
    });
    final summary = TimelineSummary.summarize(timeline);
    avgFrameResults.add(summary.computeAverageFrameBuildTimeMillis());
    worstFrameResults.add(summary.computeWorstFrameBuildTimeMillis());
    return summary;
  }

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
    print('average frame ${average(avgFrameResults)}');
    print('worst frame ${average(worstFrameResults)}');
  });

  group('BlocBuilder performance test', () {
    test('Round 1', () async {
      await runTest();
    });

    test('Round 2', () async {
      await runTest();
    });

    test('Round 3', () async {
      await runTest();
    });

    test('Round 4', () async {
      await runTest();
    });

    test('Round 5', () async {
      await runTest();
    });

    test('Round 6', () async {
      await runTest();
    });

    test('Round 7', () async {
      await runTest();
    });

    test('Round 8', () async {
      await runTest();
    });

    test('Round 9', () async {
      await runTest();
    });

    test('Round 10', () async {
      await runTest();
    });
  });
}
