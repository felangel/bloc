import 'dart:async';

import 'package:bloc_concurrency/src/debounce_first.dart';
import 'package:test/test.dart';

void main() {
  group(DebounceFirst, () {
    test('should not debounce first event', () async {
      final debounce = DebounceFirst<int>((e) => Stream.value(e));

      final inputStream = StreamController<int>();
      final transformedStream = inputStream.stream.transform(debounce);

      final events = <int>[];
      final subscription = transformedStream.listen(events.add);

      inputStream.add(1);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events[0], 1);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(events.length, 1);
      expect(events[0], 1);

      await subscription.cancel();
      await inputStream.close();
    });

    test('should debounce subsequent events', () async {
      final debounce = DebounceFirst<int>((e) => Stream.value(e));

      final inputStream = StreamController<int>();
      final transformedStream = inputStream.stream.transform(debounce);

      final events = <int>[];
      final subscription = transformedStream.listen(events.add);

      inputStream.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      inputStream
        ..add(2)
        ..add(3);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      // First event should be emitted immediately,
      // while the subsequent events are debounced
      expect(events.length, 2);
      expect(events[0], 1);
      expect(events[1], 3);

      await subscription.cancel();
      await inputStream.close();
    });
  });
}
