// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockBlocObserver extends Mock implements BlocObserver {}

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

        runZoned(() {
          CounterCubit().addError(expectedError, StackTrace.current);
        }, onError: (Object error, StackTrace stackTrace) {
          expect(
            (error as CubitUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'CounterCubit\'.',
            ),
          );
          expect(stackTrace, isNotNull);
        });
      });
    });

    group('onChange', () {
      BlocObserver observer;

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('is not called for the initial state', () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add);
        await cubit.close();
        expect(changes, isEmpty);
        verifyNever(observer.onChange(any, any));
      });

      test('is called with correct change for a single state change', () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        expect(
          changes,
          const [Change<int>(currentState: 0, nextState: 1)],
        );
        verify(observer.onChange(
          cubit,
          const Change<int>(currentState: 0, nextState: 1),
        )).called(1);
      });

      test('is called with correct changes for multiple state changes',
          () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await cubit.close();
        expect(
          changes,
          const [
            Change<int>(currentState: 0, nextState: 1),
            Change<int>(currentState: 1, nextState: 2),
          ],
        );
        verify(observer.onChange(
          cubit,
          const Change<int>(currentState: 0, nextState: 1),
        )).called(1);
        verify(observer.onChange(
          cubit,
          const Change<int>(currentState: 1, nextState: 2),
        )).called(1);
      });
    });

    group('emit', () {
      test('does nothing if cubit is closed', () async {
        final cubit = CounterCubit();
        await cubit.close();
        cubit.increment();
        await expectLater(cubit, emitsInOrder(<Matcher>[emitsDone]));
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
      test('returns a StreamSubscription', () async {
        final cubit = CounterCubit();
        final subscription = cubit.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        await subscription.cancel();
        await cubit.close();
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

    test('isBroadcast returns true', () {
      expect(CounterCubit().isBroadcast, isTrue);
    });
  });
}
