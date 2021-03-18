import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class MockBlocObserver extends Mock implements BlocObserver {}

class FakeBlocBase<S> extends Fake implements BlocBase<S> {}

void main() {
  group('Bloc Tests', () {
    group('Simple Bloc', () {
      late SimpleBloc simpleBloc;
      late MockBlocObserver observer;

      setUp(() {
        simpleBloc = SimpleBloc();
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('triggers onCreate on observer when instantiated', () {
        final bloc = SimpleBloc();
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onCreate(bloc)).called(1);
      });

      test('triggers onClose on observer when closed', () async {
        final bloc = SimpleBloc();
        await bloc.close();
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onClose(bloc)).called(1);
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(expectLater(simpleBloc.stream, emitsInOrder(expectedStates)));

        await simpleBloc.close();
      });

      test('state returns correct value initially', () {
        expect(simpleBloc.state, '');
      });

      test('should map single event to correct state', () {
        final expectedStates = ['data', emitsDone];

        expectLater(
          simpleBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              simpleBloc,
              const Transition<dynamic, String>(
                currentState: '',
                event: 'event',
                nextState: 'data',
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              simpleBloc,
              const Change<String>(currentState: '', nextState: 'data'),
            ),
          ).called(1);
          expect(simpleBloc.state, 'data');
        });

        simpleBloc
          ..add('event')
          ..close();
      });

      test('should map multiple events to correct states', () {
        final expectedStates = ['data', emitsDone];

        expectLater(
          simpleBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              simpleBloc,
              const Transition<dynamic, String>(
                currentState: '',
                event: 'event1',
                nextState: 'data',
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              simpleBloc,
              const Change<String>(currentState: '', nextState: 'data'),
            ),
          ).called(1);
          expect(simpleBloc.state, 'data');
        });

        simpleBloc
          ..add('event1')
          ..add('event2')
          ..add('event3')
          ..close();
      });

      test('is a broadcast stream', () {
        final expectedStates = ['data', emitsDone];

        expect(simpleBloc.stream.isBroadcast, isTrue);
        expectLater(simpleBloc.stream, emitsInOrder(expectedStates));
        expectLater(simpleBloc.stream, emitsInOrder(expectedStates));

        simpleBloc
          ..add('event')
          ..close();
      });

      test('multiple subscribers receive the latest state', () {
        final expectedStates = const <String>['data'];

        expectLater(simpleBloc.stream, emitsInOrder(expectedStates));
        expectLater(simpleBloc.stream, emitsInOrder(expectedStates));
        expectLater(simpleBloc.stream, emitsInOrder(expectedStates));

        simpleBloc.add('event');
      });
    });

    group('Complex Bloc', () {
      late ComplexBloc complexBloc;
      late MockBlocObserver observer;

      setUp(() {
        complexBloc = ComplexBloc();
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(
          expectLater(complexBloc.stream, emitsInOrder(expectedStates)),
        );

        await complexBloc.close();
      });

      test('state returns correct value initially', () {
        expect(complexBloc.state, ComplexStateA());
      });

      test('should map single event to correct state', () {
        final expectedStates = [ComplexStateB()];

        expectLater(
          complexBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              complexBloc,
              Transition<ComplexEvent, ComplexState>(
                currentState: ComplexStateA(),
                event: ComplexEventB(),
                nextState: ComplexStateB(),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              complexBloc,
              Change<ComplexState>(
                currentState: ComplexStateA(),
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
          ComplexStateB(),
          ComplexStateD(),
          ComplexStateA(),
          ComplexStateC(),
        ];

        unawaited(
          expectLater(complexBloc.stream, emitsInOrder(expectedStates)),
        );

        complexBloc.add(ComplexEventA());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexBloc.add(ComplexEventB());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexBloc.add(ComplexEventC());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexBloc.add(ComplexEventD());
        await Future<void>.delayed(const Duration(milliseconds: 200));
        complexBloc..add(ComplexEventC())..add(ComplexEventA());
        await Future<void>.delayed(const Duration(milliseconds: 120));
        complexBloc.add(ComplexEventC());
      });

      test('is a broadcast stream', () {
        final expectedStates = [ComplexStateB()];

        expect(complexBloc.stream.isBroadcast, isTrue);
        expectLater(complexBloc.stream, emitsInOrder(expectedStates));
        expectLater(complexBloc.stream, emitsInOrder(expectedStates));

        complexBloc.add(ComplexEventB());
      });

      test('multiple subscribers receive the latest state', () {
        final expected = <ComplexState>[ComplexStateB()];

        expectLater(complexBloc.stream, emitsInOrder(expected));
        expectLater(complexBloc.stream, emitsInOrder(expected));
        expectLater(complexBloc.stream, emitsInOrder(expected));

        complexBloc.add(ComplexEventB());
      });
    });

    group('CounterBloc', () {
      late CounterBloc counterBloc;
      late MockBlocObserver observer;
      late List<String> transitions;
      late List<CounterEvent> events;

      setUp(() {
        events = [];
        transitions = [];
        counterBloc = CounterBloc(
          onEventCallback: events.add,
          onTransitionCallback: (transition) {
            transitions.add(transition.toString());
          },
        );
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('state returns correct value initially', () {
        expect(counterBloc.state, 0);
        expect(events.isEmpty, true);
        expect(transitions.isEmpty, true);
      });

      test('single Increment event updates state to 1', () {
        final expectedStates = [1, emitsDone];
        final expectedTransitions = [
          '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }'''
        ];

        expectLater(
          counterBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expectLater(transitions, expectedTransitions);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              counterBloc,
              const Transition<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterBloc,
              const Change<int>(currentState: 0, nextState: 1),
            ),
          ).called(1);
          expect(counterBloc.state, 1);
        });

        counterBloc
          ..add(CounterEvent.increment)
          ..close();
      });

      test('multiple Increment event updates state to 3', () {
        final expectedStates = [1, 2, 3, emitsDone];
        final expectedTransitions = [
          '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }''',
          '''Transition { currentState: 1, event: CounterEvent.increment, nextState: 2 }''',
          '''Transition { currentState: 2, event: CounterEvent.increment, nextState: 3 }''',
        ];

        expectLater(
          counterBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              counterBloc,
              const Transition<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterBloc,
              const Change<int>(currentState: 0, nextState: 1),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              counterBloc,
              const Transition<CounterEvent, int>(
                currentState: 1,
                event: CounterEvent.increment,
                nextState: 2,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterBloc,
              const Change<int>(currentState: 1, nextState: 2),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              counterBloc,
              const Transition<CounterEvent, int>(
                currentState: 2,
                event: CounterEvent.increment,
                nextState: 3,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterBloc,
              const Change<int>(currentState: 2, nextState: 3),
            ),
          ).called(1);
        });

        counterBloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..close();
      });

      test('is a broadcast stream', () {
        final expectedStates = [1, emitsDone];

        expect(counterBloc.stream.isBroadcast, isTrue);
        expectLater(counterBloc.stream, emitsInOrder(expectedStates));
        expectLater(counterBloc.stream, emitsInOrder(expectedStates));

        counterBloc
          ..add(CounterEvent.increment)
          ..close();
      });

      test('multiple subscribers receive the latest state', () {
        const expected = <int>[1];

        expectLater(counterBloc.stream, emitsInOrder(expected));
        expectLater(counterBloc.stream, emitsInOrder(expected));
        expectLater(counterBloc.stream, emitsInOrder(expected));

        counterBloc.add(CounterEvent.increment);
      });
    });

    group('Async Bloc', () {
      late AsyncBloc asyncBloc;
      late MockBlocObserver observer;

      setUpAll(() {
        registerFallbackValue<BlocBase<dynamic>>(FakeBlocBase<dynamic>());
        registerFallbackValue<StackTrace>(StackTrace.empty);
      });

      setUp(() {
        asyncBloc = AsyncBloc();
        observer = MockBlocObserver();
        Bloc.observer = observer;
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(expectLater(asyncBloc.stream, emitsInOrder(expectedStates)));

        await asyncBloc.close();
      });

      test(
          'close while events are pending finishes processing pending events '
          'and does not trigger onError', () async {
        final expectedStates = <AsyncState>[
          AsyncState.initial().copyWith(isLoading: true),
          AsyncState.initial().copyWith(isSuccess: true),
        ];
        final states = <AsyncState>[];

        asyncBloc
          // ignore: deprecated_member_use_from_same_package
          ..listen(states.add)
          ..add(AsyncEvent());

        await asyncBloc.close();

        expect(states, expectedStates);
        // ignore: invalid_use_of_protected_member
        verifyNever(() => observer.onError(any(), any(), any()));
      });

      test('state returns correct value initially', () {
        expect(asyncBloc.state, AsyncState.initial());
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expectLater(
          asyncBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
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
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              asyncBloc,
              Change<AsyncState>(
                currentState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                nextState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
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
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              asyncBloc,
              Change<AsyncState>(
                currentState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
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

        asyncBloc
          ..add(AsyncEvent())
          ..close();
      });

      test('is a broadcast stream', () {
        final expectedStates = [
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expect(asyncBloc.stream.isBroadcast, isTrue);
        expectLater(asyncBloc.stream, emitsInOrder(expectedStates));
        expectLater(asyncBloc.stream, emitsInOrder(expectedStates));

        asyncBloc
          ..add(AsyncEvent())
          ..close();
      });

      test('multiple subscribers receive the latest state', () {
        final expected = <AsyncState>[
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
        ];

        expectLater(asyncBloc.stream, emitsInOrder(expected));
        expectLater(asyncBloc.stream, emitsInOrder(expected));
        expectLater(asyncBloc.stream, emitsInOrder(expected));

        asyncBloc.add(AsyncEvent());
      });
    });

    group('flatMap', () {
      test('maintains correct transition composition', () {
        final expectedTransitions = <Transition<CounterEvent, int>>[
          const Transition(
            currentState: 0,
            event: CounterEvent.decrement,
            nextState: -1,
          ),
          const Transition(
            currentState: -1,
            event: CounterEvent.increment,
            nextState: 0,
          ),
        ];

        final expectedStates = [-1, 0, emitsDone];
        final transitions = <Transition<CounterEvent, int>>[];
        final flatMapBloc = FlatMapBloc(
          onTransitionCallback: transitions.add,
        );

        expectLater(
          flatMapBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
        });
        flatMapBloc
          ..add(CounterEvent.decrement)
          ..add(CounterEvent.increment)
          ..close();
      });
    });

    group('mergeBloc', () {
      test('maintains correct transition composition', () {
        final expectedTransitions = <Transition<CounterEvent, int>>[
          const Transition(
            currentState: 0,
            event: CounterEvent.increment,
            nextState: 1,
          ),
          const Transition(
            currentState: 1,
            event: CounterEvent.decrement,
            nextState: 0,
          ),
          const Transition(
            currentState: 0,
            event: CounterEvent.decrement,
            nextState: -1,
          ),
        ];
        final expectedStates = [1, 0, -1, emitsDone];
        final transitions = <Transition<CounterEvent, int>>[];

        final bloc = MergeBloc(
          onTransitionCallback: transitions.add,
        );

        expectLater(
          bloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
        });
        bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..add(CounterEvent.decrement)
          ..add(CounterEvent.decrement)
          ..close();
      });
    });

    group('SeededBloc', () {
      test('does not emit repeated states', () {
        final seededBloc = SeededBloc(seed: 0, states: [1, 2, 1, 1]);
        final expectedStates = [1, 2, 1, emitsDone];

        expectLater(seededBloc.stream, emitsInOrder(expectedStates));

        seededBloc
          ..add('event')
          ..close();
      });

      test('can emit initial state only once', () {
        final seededBloc = SeededBloc(seed: 0, states: [0, 0]);
        final expectedStates = [0, emitsDone];

        expectLater(seededBloc.stream, emitsInOrder(expectedStates));

        seededBloc
          ..add('event')
          ..close();
      });

      test(
          'can emit initial state and '
          'continue emitting distinct states', () {
        final seededBloc = SeededBloc(seed: 0, states: [0, 0, 1]);
        final expectedStates = [0, 1, emitsDone];

        expectLater(seededBloc.stream, emitsInOrder(expectedStates));

        seededBloc
          ..add('event')
          ..close();
      });

      test('discards subsequent duplicate states (distinct events)', () {
        final seededBloc = SeededBloc(seed: 0, states: [1, 1]);
        final expectedStates = [1, emitsDone];

        expectLater(seededBloc.stream, emitsInOrder(expectedStates));

        seededBloc
          ..add('eventA')
          ..add('eventB')
          ..add('eventC')
          ..close();
      });

      test('discards subsequent duplicate states (same event)', () {
        final seededBloc = SeededBloc(seed: 0, states: [1, 1]);
        final expectedStates = [1, emitsDone];

        expectLater(seededBloc.stream, emitsInOrder(expectedStates));

        seededBloc
          ..add('event')
          ..add('event')
          ..add('event')
          ..close();
      });
    });

    group('Exception', () {
      test('does not break stream', () {
        runZonedGuarded(() {
          final expectedStates = [-1, emitsDone];
          final counterBloc = CounterExceptionBloc();

          expectLater(counterBloc.stream, emitsInOrder(expectedStates));

          counterBloc
            ..add(CounterEvent.increment)
            ..add(CounterEvent.decrement)
            ..close();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'CounterExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('addError triggers onError', () async {
        final expectedError = Exception('fatal exception');

        runZonedGuarded(() {
          OnExceptionBloc(
            exception: expectedError,
            onErrorCallback: (Object _, StackTrace __) {},
          )..addError(expectedError, StackTrace.current);
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from mapEventToState', () {
        runZonedGuarded(() {
          final exception = Exception('fatal exception');
          Object? expectedError;
          StackTrace? expectedStacktrace;

          final onExceptionBloc = OnExceptionBloc(
              exception: exception,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              });

          expectLater(
            onExceptionBloc.stream,
            emitsInOrder(<Matcher>[emitsDone]),
          ).then((dynamic _) {
            expect(expectedError, exception);
            expect(expectedStacktrace, isNotNull);
            expect(expectedStacktrace, isNot(StackTrace.empty));
          });

          onExceptionBloc
            ..add(CounterEvent.increment)
            ..close();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnExceptionBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from onEvent', () {
        runZonedGuarded(() {
          final exception = Exception('fatal exception');

          OnEventErrorBloc(exception: exception)
            ..add(CounterEvent.increment)
            ..close();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as BlocUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnEventErrorBloc\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('does not trigger onError from add', () {
        runZonedGuarded(() {
          Object? capturedError;
          StackTrace? capturedStacktrace;
          final counterBloc = CounterBloc(
            onErrorCallback: (error, stackTrace) {
              capturedError = error;
              capturedStacktrace = stackTrace;
            },
          );

          expectLater(
            counterBloc.stream,
            emitsInOrder(<Matcher>[emitsDone]),
          ).then((dynamic _) {
            expect(capturedError, isNull);
            expect(capturedStacktrace, isNull);
          });

          counterBloc
            ..close()
            ..add(CounterEvent.increment);
        }, (Object _, StackTrace __) {
          fail('should not throw when add is called after bloc is closed');
        });
      });
    });

    group('Error', () {
      test('does not break stream', () {
        runZonedGuarded(
          () {
            final expectedStates = [-1, emitsDone];
            final counterBloc = CounterErrorBloc();

            expectLater(counterBloc.stream, emitsInOrder(expectedStates));

            counterBloc
              ..add(CounterEvent.increment)
              ..add(CounterEvent.decrement)
              ..close();
          },
          (Object _, StackTrace __) {},
        );
      });

      test('triggers onError from mapEventToState', () {
        runZonedGuarded(
          () {
            final error = Error();
            Object? expectedError;
            StackTrace? expectedStacktrace;

            final onErrorBloc = OnErrorBloc(
              error: error,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              },
            );

            expectLater(
              onErrorBloc.stream,
              emitsInOrder(<Matcher>[emitsDone]),
            ).then((dynamic _) {
              expect(expectedError, error);
              expect(expectedStacktrace, isNotNull);
            });

            onErrorBloc
              ..add(CounterEvent.increment)
              ..close();
          },
          (Object _, StackTrace __) {},
        );
      });

      test('triggers onError from onTransition', () {
        runZonedGuarded(
          () {
            final error = Error();
            Object? expectedError;
            StackTrace? expectedStacktrace;

            final onTransitionErrorBloc = OnTransitionErrorBloc(
              error: error,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              },
            );

            expectLater(
              onTransitionErrorBloc.stream,
              emitsInOrder(<Matcher>[emitsDone]),
            ).then((dynamic _) {
              expect(expectedError, error);
              expect(expectedStacktrace, isNotNull);
              expect(onTransitionErrorBloc.state, 0);
            });

            onTransitionErrorBloc
              ..add(CounterEvent.increment)
              ..close();
          },
          (Object _, StackTrace __) {},
        );
      });
    });

    group('emit', () {
      test('updates the state', () async {
        final counterBloc = CounterBloc();
        unawaited(
          expectLater(counterBloc.stream, emitsInOrder(const <int>[42])),
        );
        counterBloc.emit(42);
        expect(counterBloc.state, 42);
        await counterBloc.close();
      });
    });

    group('close', () {
      test('emits done (sync)', () {
        final bloc = CounterBloc()..close();
        expect(bloc.stream, emitsDone);
      });

      test('emits done (async)', () async {
        final bloc = CounterBloc();
        await bloc.close();
        expect(bloc.stream, emitsDone);
      });
    });
  });
}
