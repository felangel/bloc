import 'dart:async';

class Ticker {
  Stream<int> tick() =>
      Stream.periodic(Duration(seconds: 1), (x) => x).take(10);
}
