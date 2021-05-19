import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/ticker.dart';

void main() {
  group('Ticker', () {
    final ticker = Ticker();
    test('ticker emits 5 ticks from 4-0 every 1 second', () {
      expectLater(ticker.tick(ticks: 5), emitsInOrder(<int>[4, 3, 2, 1, 0]));
    });
  });
}
