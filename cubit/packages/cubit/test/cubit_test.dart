import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockCubitObserver extends Mock implements CubitObserver {}

void main() {
  group('cubit', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterCubit().state, 0);
      });
    });

    group('onTransition', () {
      CubitObserver observer;

      setUp(() {
        observer = MockCubitObserver();
        Cubit.observer = observer;
      });

      test('is not called for the initial state', () async {
        final transitions = <Transition<int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add);
        await cubit.close();
        expect(transitions, isEmpty);
        verifyNever(observer.onTransition(any, any));
      });

      test('is called with correct transition for a single state change',
          () async {
        final transitions = <Transition<int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        expect(
          transitions,
          const [Transition(currentState: 0, nextState: 1)],
        );
        verify(observer.onTransition(
          cubit,
          const Transition<int>(currentState: 0, nextState: 1),
        )).called(1);
      });

      test('is called with correct transitions for multiple state changes',
          () async {
        final transitions = <Transition<int>>[];
        final cubit = CounterCubit(onTransitionCallback: transitions.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        expect(
          transitions,
          const [
            Transition(currentState: 0, nextState: 1),
            Transition(currentState: 1, nextState: 2),
          ],
        );
        verify(observer.onTransition(
          cubit,
          const Transition<int>(currentState: 0, nextState: 1),
        )).called(1);
        verify(observer.onTransition(
          cubit,
          const Transition<int>(currentState: 1, nextState: 2),
        )).called(1);
      });
    });

    group('emit', () {
      test('does nothing if cubit is closed', () async {
        final cubit = CounterCubit();
        await cubit.close();
        cubit.increment();
        await expectLater(cubit, emitsInOrder(<Matcher>[equals(0), emitsDone]));
      });

      test('emits states in the correct order', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1]);
      });

      test('does not emit duplicate states', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero);
        cubit
          ..emitState(1)
          ..emitState(1)
          ..emitState(2)
          ..emitState(2)
          ..emitState(3)
          ..emitState(3);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 3]);
      });
    });

    group('listen', () {
      test('returns a StreamSubscription', () async {
        final cubit = CounterCubit();
        final subscription = cubit.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        await subscription.cancel();
        await cubit.close();
      });

      test('receives initial state immediately upon subscribing', () async {
        final states = <int>[];
        final cubit = CounterCubit()..listen(states.add);
        await cubit.close();
        expect(states, [equals(0)]);
      });

      test('receives fake async states immediately upon subscribing', () async {
        final states = <int>[];
        final cubit = FakeAsyncCounterCubit()..skip(1).listen(states.add);
        await Future.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        expect(states, [equals(1)]);
      });

      test('can call listen multiple times', () async {
        final states = <int>[];
        final cubit = CounterCubit()..listen(states.add)..listen(states.add);
        await cubit.close();
        expect(states, [equals(0), equals(0)]);
      });
    });

    test('isBroadcast returns true', () {
      expect(CounterCubit().isBroadcast, isTrue);
    });
  });
}
