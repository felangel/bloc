import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';
import 'mocks/mocks.dart';

void main() {
  group('Cubit', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterCubit().state, 0);
      });
    });

    group('addError', () {
      BlocObserver observer;

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('triggers onError', () async {
        final expectedError = Exception('fatal exception');

        runZonedGuarded(() {
          CounterCubit().addError(expectedError, StackTrace.current);
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'CounterCubit\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });
    });

    group('onTransition', () {
      late MockBlocObserver observer;

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('is not called for the initial state', () async {
        final transitions = <Transition<Null, int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add);
        await cubit.close();
        expect(transitions, isEmpty);
      });

      test('is called with correct change for a single state change', () async {
        final transitions = <Transition<Null, int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add)
          ..increment();
        await cubit.close();
        expect(
          transitions,
          const [Transition<Null, int>(currentState: 0, nextState: 1)],
        );
      });

      test('is called with correct transitions for multiple state transitions',
          () async {
        final transitions = <Transition<Null, int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add)
          ..increment()
          ..increment();
        await cubit.close();
        expect(
          transitions,
          const [
            Transition<Null, int>(currentState: 0, nextState: 1),
            Transition<Null, int>(currentState: 1, nextState: 2),
          ],
        );
      });
    });

    group('mapEventToState', () {
      test('throws StateError', () {
        final cubit = CounterCubit();
        final message = 'mapEventToState should never be invoked '
            'on an instance of type Cubit';
        expect(
          () => cubit.mapEventToState(null),
          throwsA(
            isA<StateError>().having((e) => e.message, 'message', message),
          ),
        );
      });
    });

    group('emit', () {
      test('does nothing if cubit is closed (indirect)', () {
        final cubit = CounterCubit();
        expectLater(cubit, emitsInOrder(<Matcher>[equals(1), emitsDone]));
        cubit
          ..increment()
          ..close()
          ..increment();
      });

      test('does nothing if cubit is closed (direct)', () {
        final cubit = CounterCubit();
        expectLater(cubit, emitsInOrder(<Matcher>[equals(1), emitsDone]));
        cubit
          ..emit(1)
          ..close()
          ..emit(2);
      });

      test('can be invoked directly within a test', () {
        final cubit = CounterCubit()
          ..emit(100)
          ..close();
        expect(cubit.state, 100);
      });

      test('emits states in the correct order', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        cubit.increment();
        await cubit.close();
        await subscription.cancel();
        expect(states, [1]);
      });

      test('can emit initial state only once', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.listen(states.add);
        cubit..emitState(0)..emitState(0);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0]);
      });

      test(
          'can emit initial state and '
          'continue emitting distinct states', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.listen(states.add);
        cubit..emitState(0)..emitState(1);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1]);
      });

      test('does not emit duplicate states', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.listen(states.add);
        cubit
          ..emitState(1)
          ..emitState(1)
          ..emitState(2)
          ..emitState(2)
          ..emitState(3)
          ..emitState(3);
        await cubit.close();
        await subscription.cancel();
        expect(states, [1, 2, 3]);
      });
    });

    group('listen', () {
      test('returns a StreamSubscription', () {
        final cubit = CounterCubit();
        final subscription = cubit.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        subscription.cancel();
        cubit.close();
      });

      test('does not receive current state upon subscribing', () async {
        final states = <int>[];
        final cubit = CounterCubit()..listen(states.add);
        await cubit.close();
        expect(states, isEmpty);
      });

      test('receives single async state', () async {
        final states = <int>[];
        final cubit = FakeAsyncCounterCubit()..listen(states.add);
        await cubit.increment();
        await cubit.close();
        expect(states, [equals(1)]);
      });

      test('receives multiple async states', () async {
        final states = <int>[];
        final cubit = FakeAsyncCounterCubit()..listen(states.add);
        await cubit.increment();
        await cubit.increment();
        await cubit.increment();
        await cubit.close();
        expect(states, [equals(1), equals(2), equals(3)]);
      });

      test('can call listen multiple times', () async {
        final states = <int>[];
        final cubit = CounterCubit()
          ..listen(states.add)
          ..listen(states.add)
          ..increment();
        await cubit.close();
        expect(states, [equals(1), equals(1)]);
      });
    });

    group('close', () {
      late MockBlocObserver observer;

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('triggers onClose on observer', () async {
        final cubit = CounterCubit();
        await cubit.close();
        expect(observer.onCloseCalls, [OnCloseCall(cubit)]);
      });

      test('emits done (sync)', () {
        final cubit = CounterCubit()..close();
        expect(cubit, emitsDone);
      });

      test('emits done (async)', () async {
        final cubit = CounterCubit();
        await cubit.close();
        expect(cubit, emitsDone);
      });
    });

    test('isBroadcast returns true', () {
      expect(CounterCubit().isBroadcast, isTrue);
    });
  });
}
