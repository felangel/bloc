// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import './helpers/helpers.dart';

class MockBlocObserver extends Mock implements BlocObserver {}

void main() {
  group('Bloc Tests', () {
    group('Simple Bloc', () {
      SimpleBloc simpleBloc;
      BlocObserver observer;

      setUp(() {
        simpleBloc = SimpleBloc();
        observer = MockBlocObserver();
        when(observer.onTransition(any, any)).thenReturn(null);

        Bloc.observer = observer;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = ['', emitsDone];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        );

        simpleBloc.close();
      });

      test('state returns correct value initially', () {
        expect(simpleBloc.state, '');
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await simpleBloc.first;
        expect(initialState, simpleBloc.state);
      });

      test('should map single event to correct state', () {
        final expectedStates = ['', 'data', emitsDone];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          verify(
            observer.onTransition(
              simpleBloc,
              Transition<dynamic, String>(
                currentState: '',
                event: 'event',
                nextState: 'data',
              ),
            ),
          ).called(1);
          expect(simpleBloc.state, 'data');
        });

        simpleBloc.add('event');
        simpleBloc.close();
      });

      test('should map multiple events to correct states', () {
        final expectedStates = ['', 'data', emitsDone];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          verify(
            observer.onTransition(
              simpleBloc,
              Transition<dynamic, String>(
                currentState: '',
                event: 'event1',
                nextState: 'data',
              ),
            ),
          ).called(1);
          expect(simpleBloc.state, 'data');
        });

        simpleBloc.add('event1');
        simpleBloc.add('event2');
        simpleBloc.add('event3');

        simpleBloc.close();
      });

      test('is a broadcast stream', () {
        final expectedStates = ['', 'data', emitsDone];

        expect(simpleBloc.isBroadcast, isTrue);
        expectLater(simpleBloc, emitsInOrder(expectedStates));
        expectLater(simpleBloc, emitsInOrder(expectedStates));

        simpleBloc.add('event');

        simpleBloc.close();
      });

      test('multiple subscribers receive the latest state', () async {
        simpleBloc.add('event');
        await expectLater(simpleBloc, emitsInOrder(['', 'data']));
        await expectLater(simpleBloc, emits('data'));
        await expectLater(simpleBloc, emits('data'));
      });
    });

    group('Complex Bloc', () {
      ComplexBloc complexBloc;
      BlocObserver observer;

      setUp(() {
        complexBloc = ComplexBloc();
        observer = MockBlocObserver();
        when(observer.onTransition(any, any)).thenReturn(null);

        Bloc.observer = observer;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = [ComplexStateA(), emitsDone];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        );

        complexBloc.close();
      });

      test('state returns correct value initially', () {
        expect(complexBloc.state, ComplexStateA());
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await complexBloc.first;
        expect(initialState, complexBloc.state);
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          ComplexStateA(),
          ComplexStateB(),
        ];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          verify(
            observer.onTransition(
              complexBloc,
              Transition<ComplexEvent, ComplexState>(
                currentState: ComplexStateA(),
                event: ComplexEventB(),
                nextState: ComplexStateB(),
              ),
            ),
          ).called(1);
          expect(complexBloc.state, ComplexStateB());
        });

        complexBloc.add(ComplexEventB());
      });

      test('should map multiple events to correct states', () async {
        final expectedStates = [
          ComplexStateA(),
          ComplexStateB(),
          ComplexStateD(),
          ComplexStateA(),
          ComplexStateC(),
        ];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        );

        complexBloc.add(ComplexEventA());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.add(ComplexEventB());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.add(ComplexEventC());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.add(ComplexEventD());
        await Future<void>.delayed(Duration(milliseconds: 200));
        complexBloc.add(ComplexEventC());
        complexBloc.add(ComplexEventA());
        await Future<void>.delayed(Duration(milliseconds: 120));
        complexBloc.add(ComplexEventC());
      });

      test('is a broadcast stream', () {
        final expectedStates = [ComplexStateA(), ComplexStateB()];

        expect(complexBloc.isBroadcast, isTrue);
        expectLater(complexBloc, emitsInOrder(expectedStates));
        expectLater(complexBloc, emitsInOrder(expectedStates));

        complexBloc.add(ComplexEventB());
      });

      test('multiple subscribers receive the latest state', () async {
        complexBloc.add(ComplexEventB());
        await expectLater(
          complexBloc,
          emitsInOrder([ComplexStateA(), ComplexStateB()]),
        );
        await expectLater(complexBloc, emits(ComplexStateB()));
        await expectLater(complexBloc, emits(ComplexStateB()));
      });
    });

    group('CounterBloc', () {
      CounterBloc counterBloc;
      BlocObserver observer;
      List<String> transitions;
      List<CounterEvent> events;

      void onEventCallback(event) {
        events.add(event);
      }

      void onTransitionCallback(transition) {
        transitions.add(transition.toString());
      }

      setUp(() {
        events = [];
        transitions = [];
        counterBloc = CounterBloc(
          onEventCallback: onEventCallback,
          onTransitionCallback: onTransitionCallback,
        );
        observer = MockBlocObserver();
        when(observer.onTransition(any, any)).thenReturn(null);

        Bloc.observer = observer;
      });

      test('state returns correct value initially', () {
        expect(counterBloc.state, 0);
        expect(events.isEmpty, true);
        expect(transitions.isEmpty, true);
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await counterBloc.first;
        expect(initialState, counterBloc.state);
      });

      test('single Increment event updates state to 1', () {
        final expectedStates = [0, 1, emitsDone];
        final expectedTransitions = [
          'Transition { currentState: 0, event: CounterEvent.increment, '
              'nextState: 1 }'
        ];

        expectLater(
          counterBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          expectLater(transitions, expectedTransitions);
          verify(
            observer.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          expect(counterBloc.state, 1);
        });

        counterBloc.add(CounterEvent.increment);

        counterBloc.close();
      });

      test('multiple Increment event updates state to 3', () {
        final expectedStates = [0, 1, 2, 3, emitsDone];
        final expectedTransitions = [
          'Transition { currentState: 0, event: CounterEvent.increment, '
              'nextState: 1 }',
          'Transition { currentState: 1, event: CounterEvent.increment, '
              'nextState: 2 }',
          'Transition { currentState: 2, event: CounterEvent.increment, '
              'nextState: 3 }',
        ];

        expectLater(
          counterBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          expect(transitions, expectedTransitions);
          verify(
            observer.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            observer.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 1,
                event: CounterEvent.increment,
                nextState: 2,
              ),
            ),
          ).called(1);
          verify(
            observer.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 2,
                event: CounterEvent.increment,
                nextState: 3,
              ),
            ),
          ).called(1);
          expect(counterBloc.state, 3);
        });

        counterBloc.add(CounterEvent.increment);
        counterBloc.add(CounterEvent.increment);
        counterBloc.add(CounterEvent.increment);

        counterBloc.close();
      });

      test('is a broadcast stream', () {
        final expectedStates = [0, 1, emitsDone];

        expect(counterBloc.isBroadcast, isTrue);
        expectLater(counterBloc, emitsInOrder(expectedStates));
        expectLater(counterBloc, emitsInOrder(expectedStates));

        counterBloc.add(CounterEvent.increment);

        counterBloc.close();
      });

      test('multiple subscribers receive the latest state', () async {
        counterBloc.add(CounterEvent.increment);
        await expectLater(counterBloc, emitsInOrder([0, 1]));
        await expectLater(counterBloc, emits(1));
        await expectLater(counterBloc, emits(1));
      });
    });

    group('Async Bloc', () {
      AsyncBloc asyncBloc;
      BlocObserver observer;

      setUp(() {
        asyncBloc = AsyncBloc();
        observer = MockBlocObserver();
        when(observer.onTransition(any, any)).thenReturn(null);

        Bloc.observer = observer;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = [AsyncState.initial(), emitsDone];

        expectLater(
          asyncBloc,
          emitsInOrder(expectedStates),
        );

        asyncBloc.close();
      });

      test(
          'close while events are pending finishes processing pending events '
          'and does not trigger onError', () async {
        final expectedStates = <AsyncState>[
          AsyncState.initial(),
          AsyncState.initial().copyWith(isLoading: true),
          AsyncState.initial().copyWith(isSuccess: true),
        ];
        final states = <AsyncState>[];
        asyncBloc.listen(states.add);

        asyncBloc.add(AsyncEvent());
        await asyncBloc.close();
        expect(states, expectedStates);

        verifyNever(observer.onError(any, any, any));
      });

      test('state returns correct value initially', () {
        expect(asyncBloc.state, AsyncState.initial());
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await asyncBloc.first;
        expect(initialState, asyncBloc.state);
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          AsyncState(isLoading: false, hasError: false, isSuccess: false),
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expectLater(
          asyncBloc,
          emitsInOrder(expectedStates),
        ).then((_) {
          verify(
            observer.onTransition(
              asyncBloc,
              Transition<AsyncEvent, AsyncState>(
                currentState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
              ),
            ),
          ).called(1);
          verify(
            observer.onTransition(
              asyncBloc,
              Transition<AsyncEvent, AsyncState>(
                currentState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: true,
                ),
              ),
            ),
          ).called(1);
          expect(
            asyncBloc.state,
            AsyncState(
              isLoading: false,
              hasError: false,
              isSuccess: true,
            ),
          );
        });

        asyncBloc.add(AsyncEvent());

        asyncBloc.close();
      });

      test('is a broadcast stream', () {
        final expectedStates = [
          AsyncState(isLoading: false, hasError: false, isSuccess: false),
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expect(asyncBloc.isBroadcast, isTrue);
        expectLater(asyncBloc, emitsInOrder(expectedStates));
        expectLater(asyncBloc, emitsInOrder(expectedStates));

        asyncBloc.add(AsyncEvent());

        asyncBloc.close();
      });

      test('multiple subscribers receive the latest state', () async {
        asyncBloc.add(AsyncEvent());
        await expectLater(
          asyncBloc,
          emitsInOrder([
            AsyncState(isLoading: false, hasError: false, isSuccess: false),
            AsyncState(isLoading: true, hasError: false, isSuccess: false),
            AsyncState(isLoading: false, hasError: false, isSuccess: true),
          ]),
        );
        await expectLater(
          asyncBloc,
          emits(AsyncState(isLoading: false, hasError: false, isSuccess: true)),
        );
        await expectLater(
          asyncBloc,
          emits(AsyncState(isLoading: false, hasError: false, isSuccess: true)),
        );
      });
    });

    group('flatMap', () {
      test('maintains correct transition composition', () {
        final expectedTransitions = <Transition<CounterEvent, int>>[
          Transition(
            currentState: 0,
            event: CounterEvent.decrement,
            nextState: -1,
          ),
          Transition(
            currentState: -1,
            event: CounterEvent.increment,
            nextState: 0,
          ),
        ];
        final expectedStates = [0, -1, 0, emitsDone];
        final transitions = <Transition<CounterEvent, int>>[];

        final flatMapBloc = FlatMapBloc(onTransitionCallback: transitions.add);

        expectLater(flatMapBloc, emitsInOrder(expectedStates)).then((_) {
          expect(transitions, expectedTransitions);
        });
        flatMapBloc.add(CounterEvent.decrement);
        flatMapBloc.add(CounterEvent.increment);

        flatMapBloc.close();
      });
    });

    group('SeededBloc', () {
      test('does not emit repeated states', () {
        final seededBloc = SeededBloc(seed: 0, states: [1, 2, 1, 1]);
        final expectedStates = [0, 1, 2, 1, emitsDone];

        expectLater(
          seededBloc,
          emitsInOrder(expectedStates),
        );
        seededBloc.add('event');

        seededBloc.close();
      });

      test('discards subsequent duplicate states (distinct events)', () {
        final seededBloc = SeededBloc(seed: 0, states: [0]);
        final expectedStates = [0, emitsDone];

        expectLater(
          seededBloc,
          emitsInOrder(expectedStates),
        );

        seededBloc.add('eventA');
        seededBloc.add('eventB');
        seededBloc.add('eventC');

        seededBloc.close();
      });

      test('discards subsequent duplicate states (same event)', () {
        final seededBloc = SeededBloc(seed: 0, states: [0]);
        final expectedStates = [0, emitsDone];

        expectLater(
          seededBloc,
          emitsInOrder(expectedStates),
        );

        seededBloc.add('event');
        seededBloc.add('event');
        seededBloc.add('event');

        seededBloc.close();
      });
    });

    group('Exception', () {
      test('does not break stream', () {
        runZoned(() {
          final expectedStates = [0, -1, emitsDone];
          final counterBloc = CounterExceptionBloc();

          expectLater(counterBloc, emitsInOrder(expectedStates));

          counterBloc.add(CounterEvent.increment);
          counterBloc.add(CounterEvent.decrement);

          counterBloc.close();
        }, onError: (error, stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in bloc Instance of \'CounterExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
        });
      });

      test('addError triggers onError', () async {
        final expectedError = Exception('fatal exception');

        runZoned(() {
          final onExceptionBloc = OnExceptionBloc(
            exception: expectedError,
            onErrorCallback: (error, stackTrace) {},
          );

          onExceptionBloc.addError(expectedError, StackTrace.current);
        }, onError: (error, stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in bloc Instance of \'OnExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
        });
      });

      test('triggers onError from mapEventToState', () {
        runZoned(() {
          final exception = Exception('fatal exception');
          Object expectedError;
          StackTrace expectedStacktrace;

          final onExceptionBloc = OnExceptionBloc(
              exception: exception,
              onErrorCallback: (error, stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              });

          expectLater(
            onExceptionBloc,
            emitsInOrder([0, emitsDone]),
          ).then((_) {
            expect(expectedError, exception);
            expect(expectedStacktrace, isNotNull);
          });

          onExceptionBloc.add(CounterEvent.increment);

          onExceptionBloc.close();
        }, onError: (error, stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in bloc Instance of \'OnExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
        });
      });

      test('triggers onError from onEvent', () {
        runZoned(() {
          final exception = Exception('fatal exception');

          final onEventErrorBloc = OnEventErrorBloc(exception: exception);

          onEventErrorBloc.add(CounterEvent.increment);

          onEventErrorBloc.close();
        }, onError: (error, stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in bloc Instance of \'OnEventErrorBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
        });
      });

      test('does not triggers onError from add', () {
        runZoned(() {
          Object capturedError;
          StackTrace capturedStacktrace;
          final counterBloc = CounterBloc(
            onErrorCallback: (error, stackTrace) {
              capturedError = error;
              capturedStacktrace = stackTrace;
            },
          );

          expectLater(
            counterBloc,
            emitsInOrder([0, emitsDone]),
          ).then((_) {
            expect(capturedError, isNull);
            expect(capturedStacktrace, isNull);
          });

          counterBloc.close();

          counterBloc.add(CounterEvent.increment);
        }, onError: (error, stackTrace) {
          fail('should not throw when add is called after bloc is closed');
        });
      });
    });

    group('Error', () {
      test('does not break stream', () {
        runZoned(() {
          final expectedStates = [0, -1, emitsDone];
          final counterBloc = CounterErrorBloc();

          expectLater(counterBloc, emitsInOrder(expectedStates));

          counterBloc.add(CounterEvent.increment);
          counterBloc.add(CounterEvent.decrement);

          counterBloc.close();
        }, onError: (_, __) {});
      });

      test('triggers onError from mapEventToState', () {
        runZoned(() {
          final error = Error();
          Object expectedError;
          StackTrace expectedStacktrace;

          final onErrorBloc = OnErrorBloc(
            error: error,
            onErrorCallback: (error, stackTrace) {
              expectedError = error;
              expectedStacktrace = stackTrace;
            },
          );

          expectLater(
            onErrorBloc,
            emitsInOrder([0, emitsDone]),
          ).then((_) {
            expect(expectedError, error);
            expect(expectedStacktrace, isNotNull);
          });

          onErrorBloc.add(CounterEvent.increment);

          onErrorBloc.close();
        }, onError: (_, __) {});
      });

      test('triggers onError from onTransition', () {
        runZoned(() {
          final error = Error();
          Object expectedError;
          StackTrace expectedStacktrace;

          final onTransitionErrorBloc = OnTransitionErrorBloc(
            error: error,
            onErrorCallback: (error, stackTrace) {
              expectedError = error;
              expectedStacktrace = stackTrace;
            },
          );

          expectLater(
            onTransitionErrorBloc,
            emitsInOrder([0, emitsDone]),
          ).then((_) {
            expect(expectedError, error);
            expect(expectedStacktrace, isNotNull);
            expect(onTransitionErrorBloc.state, 0);
          });

          onTransitionErrorBloc.add(CounterEvent.increment);

          onTransitionErrorBloc.close();
        }, onError: (_, __) {});
      });
    });

    group('emit', () {
      test('updates the state', () async {
        final counterBloc = CounterBloc();
        expectLater(counterBloc, emitsInOrder([42]));
        counterBloc.emit(42);
        await counterBloc.close();
      });
    });
  });
}
