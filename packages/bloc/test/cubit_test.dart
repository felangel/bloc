import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockBlocObserver extends Mock implements BlocObserver {}

class FakeBlocBase<S> extends Fake implements BlocBase<S> {}

class FakeChange<S> extends Fake implements Change<S> {}

void main() {
  group('Cubit', () {
    group('constructor', () {
      late BlocObserver observer;

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('triggers onCreate on observer', () {
        final cubit = CounterCubit();
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onCreate(cubit)).called(1);
      });
    });

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

    group('onChange', () {
      late BlocObserver observer;

      setUpAll(() {
        registerFallbackValue<BlocBase<dynamic>>(FakeBlocBase<dynamic>());
        registerFallbackValue<Change<dynamic>>(FakeChange<dynamic>());
      });

      setUp(() {
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('is not called for the initial state', () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add);
        await cubit.close();
        expect(changes, isEmpty);
        // ignore: invalid_use_of_protected_member
        verifyNever(() => observer.onChange(any(), any()));
      });

      test('is called with correct change for a single state change', () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add)..increment();
        await cubit.close();
        expect(
          changes,
          const [Change<int>(currentState: 0, nextState: 1)],
        );
        verify(
          // ignore: invalid_use_of_protected_member
          () => observer.onChange(
            cubit,
            const Change<int>(currentState: 0, nextState: 1),
          ),
        ).called(1);
      });

      test('is called with correct changes for multiple state changes',
          () async {
        final changes = <Change<int>>[];
        final cubit = CounterCubit(onChangeCallback: changes.add)
          ..increment()
          ..increment();
        await cubit.close();
        expect(
          changes,
          const [
            Change<int>(currentState: 0, nextState: 1),
            Change<int>(currentState: 1, nextState: 2),
          ],
        );
        verify(
          // ignore: invalid_use_of_protected_member
          () => observer.onChange(
            cubit,
            const Change<int>(currentState: 0, nextState: 1),
          ),
        ).called(1);
        verify(
          // ignore: invalid_use_of_protected_member
          () => observer.onChange(
            cubit,
            const Change<int>(currentState: 1, nextState: 2),
          ),
        ).called(1);
      });
    });

    group('emit', () {
      test('does nothing if cubit is closed (indirect)', () {
        final cubit = CounterCubit();
        expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[equals(1), emitsDone]),
        );
        cubit
          ..increment()
          ..close()
          ..increment();
      });

      test('does nothing if cubit is closed (direct)', () {
        final cubit = CounterCubit();
        expectLater(
          cubit.stream,
          emitsInOrder(<Matcher>[equals(1), emitsDone]),
        );
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
        final subscription = cubit.stream.listen(states.add);
        cubit.increment();
        await cubit.close();
        await subscription.cancel();
        expect(states, [1]);
      });

      test('can emit initial state only once', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.stream.listen(states.add);
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
        final subscription = cubit.stream.listen(states.add);
        cubit..emitState(0)..emitState(1);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1]);
      });

      test('does not emit duplicate states', () async {
        final states = <int>[];
        final cubit = SeededCubit(initialState: 0);
        final subscription = cubit.stream.listen(states.add);
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
        final subscription = cubit.stream.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        subscription.cancel();
        cubit.close();
      });

      test('does not receive current state upon subscribing', () async {
        final states = <int>[];
        final cubit = CounterCubit()..stream.listen(states.add);
        await cubit.close();
        expect(states, isEmpty);
      });

      test('receives single async state', () async {
        final states = <int>[];
        final cubit = FakeAsyncCounterCubit()..stream.listen(states.add);
        await cubit.increment();
        await cubit.close();
        expect(states, [equals(1)]);
      });

      test('receives multiple async states', () async {
        final states = <int>[];
        final cubit = FakeAsyncCounterCubit()..stream.listen(states.add);
        await cubit.increment();
        await cubit.increment();
        await cubit.increment();
        await cubit.close();
        expect(states, [equals(1), equals(2), equals(3)]);
      });

      test('can call listen multiple times', () async {
        final states = <int>[];
        final cubit = CounterCubit()
          ..stream.listen(states.add)
          ..stream.listen(states.add)
          ..increment();
        await cubit.close();
        expect(states, [equals(1), equals(1)]);
      });
    });

    group('listen (legacy)', () {
      test('returns a StreamSubscription', () {
        final cubit = CounterCubit();
        // ignore: deprecated_member_use_from_same_package
        final subscription = cubit.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        subscription.cancel();
        cubit.close();
      });

      test('does not receive current state upon subscribing', () async {
        final states = <int>[];
        // ignore: deprecated_member_use_from_same_package
        final cubit = CounterCubit()..listen(states.add);
        await cubit.close();
        expect(states, isEmpty);
      });

      test('receives single async state', () async {
        final states = <int>[];
        // ignore: deprecated_member_use_from_same_package
        final cubit = FakeAsyncCounterCubit()..listen(states.add);
        await cubit.increment();
        await cubit.close();
        expect(states, [equals(1)]);
      });

      test('receives multiple async states', () async {
        final states = <int>[];
        // ignore: deprecated_member_use_from_same_package
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
          // ignore: deprecated_member_use_from_same_package
          ..listen(states.add)
          // ignore: deprecated_member_use_from_same_package
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
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onClose(cubit)).called(1);
      });

      test('emits done (sync)', () {
        final cubit = CounterCubit()..close();
        expect(cubit.stream, emitsDone);
      });

      test('emits done (async)', () async {
        final cubit = CounterCubit();
        await cubit.close();
        expect(cubit.stream, emitsDone);
      });
    });
  });
}
