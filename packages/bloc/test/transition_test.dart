import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:bloc/bloc.dart';

@immutable
abstract class TransitionEvent {}

@immutable
abstract class TransitionState {}

class SimpleTransitionEvent extends TransitionEvent {}

class SimpleTransitionState extends TransitionState {}

class CounterEvent extends TransitionEvent {
  final String eventData;
  CounterEvent(this.eventData);

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
  final int count;
  CounterState(this.count);

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
  group('Transition Tests', () {
    group('constructor', () {
      test(
          'should not throw assertion error when initialized '
          'with a null currentState', () {
        expect(
          () => Transition<TransitionEvent, TransitionState>(
            currentState: null,
            event: SimpleTransitionEvent(),
            nextState: SimpleTransitionState(),
          ),
          isNot(throwsA(
            TypeMatcher<AssertionError>(),
          )),
        );
      });

      test(
          'should not throw assertion error when initialized with a null event',
          () {
        expect(
          () => Transition<TransitionEvent, TransitionState>(
            currentState: SimpleTransitionState(),
            event: null,
            nextState: SimpleTransitionState(),
          ),
          isNot(throwsA(
            TypeMatcher<AssertionError>(),
          )),
        );
      });

      test(
          'should not throw assertion error '
          'when initialized with a null nextState', () {
        expect(
          () => Transition<TransitionEvent, TransitionState>(
            currentState: SimpleTransitionState(),
            event: SimpleTransitionEvent(),
            nextState: null,
          ),
          isNot(throwsA(
            TypeMatcher<AssertionError>(),
          )),
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
        } on dynamic catch (_) {
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
      test('should return correct string representation of Transition', () {
        final transition = Transition<CounterEvent, CounterState>(
          currentState: CounterState(0),
          event: CounterEvent('increment'),
          nextState: CounterState(1),
        );

        expect(
            transition.toString(),
            'Transition { currentState: ${transition.currentState.toString()}, '
            'event: ${transition.event.toString()}, '
            'nextState: ${transition.nextState.toString()} }');
      });
    });
  });
}
