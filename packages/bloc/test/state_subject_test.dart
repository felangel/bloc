import 'package:bloc/src/state_subject.dart';
import 'package:test/test.dart';

void main() {
  group('State subject', () {
    test('emits the most recently emitted item to every subscriber', () async {
      final subject = StateSubject<int>.seeded(0);

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject, emits(3));
      await expectLater(subject, emits(3));
      await expectLater(subject, emits(3));
    });

    test('emits all emitted items correctly to every subscriber', () {
      final subject = StateSubject<int>.seeded(0);

      expectLater(subject, emitsInOrder([0, 1, 2, 3]));
      expectLater(subject, emitsInOrder([0, 1, 2, 3]));
      expectLater(subject, emitsInOrder([0, 1, 2, 3]));

      subject.add(1);
      subject.add(2);

      expectLater(subject, emitsInOrder([2, 3]));
      expectLater(subject, emitsInOrder([2, 3]));
      expectLater(subject, emitsInOrder([2, 3]));

      subject.add(3);
    });

    test('emits errors to every subscriber', () async {
      final subject = StateSubject<int>.seeded(0);

      subject.add(1);
      subject.add(2);
      subject.add(3);
      subject.addError(Exception('Something went wrong'));

      await expectLater(subject, emitsError(isException));
      await expectLater(subject, emitsError(isException));
      await expectLater(subject, emitsError(isException));

      expect(subject.value, isNull);
    });

    test('emits the seed item if no new items have been emitted', () async {
      final subject = StateSubject<int>.seeded(1);

      await expectLater(subject, emits(1));
      await expectLater(subject, emits(1));
      await expectLater(subject, emits(1));
    });

    test('emits the null seed item if no new items have been emitted',
            () async {
      final subject = StateSubject<int>.seeded(null);

      await expectLater(subject, emits(isNull));
      await expectLater(subject, emits(isNull));
      await expectLater(subject, emits(isNull));
    });

    test('can synchronously get the initial value', () {
      final subject = StateSubject<int>.seeded(1);

      expect(subject.value, 1);
    });

    test('can synchronously get the initial null value', () {
      final subject = StateSubject<int>.seeded(null);

      expect(subject.value, null);
    });

    test('is always treated as a broadcast Stream', () async {
      final subject = StateSubject<int>.seeded(null);
      final modified = subject.asyncMap((event) => Future.value(event));

      expect(subject.isBroadcast, isTrue);
      expect(modified.isBroadcast, isTrue);
    });

    test('correctly closes done', () async {
      final subject = StateSubject<void>.seeded(null);

      subject.close();

      await expectLater(subject.done, completes);
    });
  });
}
