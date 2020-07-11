import 'package:test/test.dart';
import 'package:bloc/bloc.dart';

void main() {
  group('Change Tests', () {
    group('constructor', () {
      test(
          'should not throw assertion error when initialized '
          'with a null currentState', () {
        expect(
          () => const Change<int>(currentState: null, nextState: 1),
          isNot(throwsA(isA<AssertionError>())),
        );
      });

      test(
          'should not throw assertion error '
          'when initialized with a null nextState', () {
        expect(
          () => const Change<int>(currentState: 0, nextState: null),
          isNot(throwsA(isA<AssertionError>())),
        );
      });

      test(
          'should not throw assertion error when initialized with '
          'all required parameters', () {
        try {
          const Change<int>(currentState: 0, nextState: 1);
        } on dynamic catch (_) {
          fail(
            'should not throw error when initialized '
            'with all required parameters',
          );
        }
      });
    });

    group('== operator', () {
      test('should return true if 2 Changes are equal', () {
        final changeA = const Change<int>(currentState: 0, nextState: 1);
        final changeB = const Change<int>(currentState: 0, nextState: 1);

        expect(changeA == changeB, isTrue);
      });

      test('should return false if 2 Changes are not equal', () {
        final changeA = const Change<int>(currentState: 0, nextState: 1);
        final changeB = const Change<int>(currentState: 0, nextState: -1);

        expect(changeA == changeB, isFalse);
      });
    });

    group('hashCode', () {
      test('should return correct hashCode', () {
        final change = const Change<int>(currentState: 0, nextState: 1);
        expect(
          change.hashCode,
          change.currentState.hashCode ^ change.nextState.hashCode,
        );
      });
    });

    group('toString', () {
      test('should return correct string representation of Change', () {
        final change = const Change<int>(currentState: 0, nextState: 1);

        expect(
          change.toString(),
          'Change { currentState: ${change.currentState.toString()}, '
          'nextState: ${change.nextState.toString()} }',
        );
      });
    });
  });
}
