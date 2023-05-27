import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

@immutable
abstract class TransitionEvent {}

@immutable
abstract class TransitionState {}

class SimpleTransitionEvent extends TransitionEvent {}

class SimpleTransitionState extends TransitionState {}

class CounterEvent extends TransitionEvent {
  CounterEvent(this.eventData);

  final String eventData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterEvent &&
          runtimeType == other.runtimeType &&
          eventData == other.eventData;

  @override
  int get hashCode => eventData.hashCode;
}

class CounterState extends TransitionState {
  CounterState(this.count);

  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

void main() {
  group('Change Tests', () {
    group('constructor', () {
      test(
          'should return normally when initialized with '
          'all required parameters', () {
        expect(
          () => const Change<int>(currentState: 0, nextState: 1),
          returnsNormally,
        );
      });
    });

    group('== operator', () {
      test('should return true if 2 Changes are equal', () {
        const changeA = Change<int>(currentState: 0, nextState: 1);
        const changeB = Change<int>(currentState: 0, nextState: 1);

        expect(changeA == changeB, isTrue);
      });

      test('should return false if 2 Changes are not equal', () {
        const changeA = Change<int>(currentState: 0, nextState: 1);
        const changeB = Change<int>(currentState: 0, nextState: -1);

        expect(changeA == changeB, isFalse);
      });
    });

    group('hashCode', () {
      test('should return correct hashCode', () {
        const change = Change<int>(currentState: 0, nextState: 1);
        expect(
          change.hashCode,
          change.currentState.hashCode ^ change.nextState.hashCode,
        );
      });
    });

    group('toString', () {
      test('should return correct string representation of Change', () {
        const change = Change<int>(currentState: 0, nextState: 1);

        expect(
          change.toString(),
          'Change { currentState: ${change.currentState}, '
          'nextState: ${change.nextState} }',
        );
      });
    });
  });

  group('Transition Tests', () {
    group('constructor', () {
      test(
          'should not throw assertion error when initialized '
          'with a null currentState', () {
        expect(
          () => Transition<TransitionEvent, TransitionState?>(
            currentState: null,
            event: SimpleTransitionEvent(),
            nextState: SimpleTransitionState(),
          ),
          isNot(throwsA(isA<AssertionError>())),
        );
      });

      test(
          'should not throw assertion error when initialized with a null event',
          () {
        expect(
          () => Transition<TransitionEvent?, TransitionState>(
            currentState: SimpleTransitionState(),
            event: null,
            nextState: SimpleTransitionState(),
          ),
          isNot(throwsA(isA<AssertionError>())),
        );
      });

      test(
          'should not throw assertion error '
          'when initialized with a null nextState', () {
        expect(
          () => Transition<TransitionEvent, TransitionState?>(
            currentState: SimpleTransitionState(),
            event: SimpleTransitionEvent(),
            nextState: null,
          ),
          isNot(throwsA(isA<AssertionError>())),
        );
      });

      test(
          'should not throw assertion error when initialized with '
          'all required parameters', () {
        try {
          Transition<TransitionEvent, TransitionState>(
            currentState: SimpleTransitionState(),
            event: SimpleTransitionEvent(),
            nextState: SimpleTransitionState(),
          );
        } catch (_) {
          fail(
            'should not throw error when initialized '
            'with all required parameters',
          );
        }
      });
    });

    group('== operator', () {
      test('should return true if 2 Transitions are equal', () {
        final transitionA = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );
        final transitionB = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );

        expect(transitionA == transitionB, true);
      });

      test('should return false if 2 Transitions are not equal', () {
        final transitionA = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );
        final transitionB = Transition<CounterEvent, CounterState>(
          currentState: CounterState(1),
          event: CounterEvent('decrement'),
          nextState: CounterState(0),
        );

        expect(transitionA == transitionB, false);
      });
    });

    group('hashCode', () {
      test('should return correct hashCode', () {
        final transition = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );
        expect(
          transition.hashCode,
          transition.currentState.hashCode ^
              transition.event.hashCode ^
              transition.nextState.hashCode,
        );
      });
    });

    group('toString', () {
      test('should return correct string representation for Transition', () {
        final transition = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );

        expect(
            transition.toString(),
            'Transition { currentState: ${transition.currentState}, '
            'event: ${transition.event}, '
            'nextState: ${transition.nextState} }');
      });
    });
  });
}
