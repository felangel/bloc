import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

Future<void> tick() => Future<void>.delayed(Duration.zero);

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
        final simpleBloc = SimpleBloc();

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
        final simpleBloc = SimpleBloc();

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
        const expectedStates = <String>['data'];

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
        final complexBloc = ComplexBloc();

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
        complexBloc
          ..add(ComplexEventC())
          ..add(ComplexEventA());
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
          '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }''',
        ];
        final counterBloc = CounterBloc(
          onEventCallback: events.add,
          onTransitionCallback: (transition) {
            transitions.add(transition.toString());
          },
        );

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
        final counterBloc = CounterBloc(
          onEventCallback: events.add,
          onTransitionCallback: (transition) {
            transitions.add(transition.toString());
          },
        );

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
        final counterBloc = CounterBloc(onTransitionCallback: transitions.add);

        expectLater(
          counterBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
        });
        counterBloc
          ..add(CounterEvent.decrement)
          ..add(CounterEvent.increment)
          ..close();
      });

      test('events are processed asynchronously', () async {
        expect(counterBloc.state, 0);
        expect(events.isEmpty, true);
        expect(transitions.isEmpty, true);

        counterBloc.add(CounterEvent.increment);

        expect(counterBloc.state, 0);
        expect(events, [CounterEvent.increment]);
        expect(transitions.isEmpty, true);

        await tick();

        expect(counterBloc.state, 1);
        expect(events, [CounterEvent.increment]);
        expect(
          transitions,
          const [
            '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }''',
          ],
        );
      });
    });

    group('Async Bloc', () {
      late AsyncBloc asyncBloc;
      late MockBlocObserver observer;

      setUpAll(() {
        registerFallbackValue(FakeBlocBase<dynamic>());
        registerFallbackValue(StackTrace.empty);
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
        final asyncBloc = AsyncBloc()
          ..stream.listen(states.add)
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
          const AsyncState(isLoading: true, hasError: false, isSuccess: false),
          const AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];
        final asyncBloc = AsyncBloc();

        expectLater(
          asyncBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              asyncBloc,
              Transition<AsyncEvent, AsyncState>(
                currentState: const AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: const AsyncState(
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
              const Change<AsyncState>(
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
                currentState: const AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: const AsyncState(
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
              const Change<AsyncState>(
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
            const AsyncState(
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

      test('should map multiple events to correct states', () {
        final expectedStates = [
          const AsyncState(isLoading: true, hasError: false, isSuccess: false),
          const AsyncState(isLoading: false, hasError: false, isSuccess: true),
          const AsyncState(isLoading: true, hasError: false, isSuccess: false),
          const AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];
        final asyncBloc = AsyncBloc();

        expectLater(
          asyncBloc.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransition(
              asyncBloc,
              Transition<AsyncEvent, AsyncState>(
                currentState: const AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: const AsyncState(
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
              const Change<AsyncState>(
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
                currentState: const AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: const AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: true,
                ),
              ),
            ),
          ).called(2);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              asyncBloc,
              const Change<AsyncState>(
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
          ).called(2);
          expect(
            asyncBloc.state,
            const AsyncState(
              isLoading: false,
              hasError: false,
              isSuccess: true,
            ),
          );
        });

        asyncBloc
          ..add(AsyncEvent())
          ..add(AsyncEvent())
          ..close();
      });

      test('is a broadcast stream', () {
        final expectedStates = [
          const AsyncState(isLoading: true, hasError: false, isSuccess: false),
          const AsyncState(isLoading: false, hasError: false, isSuccess: true),
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
          const AsyncState(isLoading: true, hasError: false, isSuccess: false),
          const AsyncState(isLoading: false, hasError: false, isSuccess: true),
        ];

        expectLater(asyncBloc.stream, emitsInOrder(expected));
        expectLater(asyncBloc.stream, emitsInOrder(expected));
        expectLater(asyncBloc.stream, emitsInOrder(expected));

        asyncBloc.add(AsyncEvent());
      });
    });

    group('MergeBloc', () {
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

    group('StreamBloc', () {
      test('cancels subscriptions correctly', () async {
        const expectedStates = [0, 1, 2, 3, 4];
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = StreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(Subscribe());

        await tick();

        controller
          ..add(0)
          ..add(1)
          ..add(2);

        await tick();

        bloc.add(Subscribe());

        await tick();

        controller
          ..add(3)
          ..add(4);

        await Future<void>.delayed(const Duration(milliseconds: 300));

        await bloc.close();
        expect(states, equals(expectedStates));
      });
    });

    group('RestartableStreamBloc', () {
      test('unawaited forEach throws AssertionError', () async {
        late final Object blocError;
        await runZonedGuarded(() async {
          final controller = StreamController<int>.broadcast();
          final bloc = RestartableStreamBloc(controller.stream)
            ..add(UnawaitedForEach());

          await tick();

          controller.add(0);

          await tick();

          await Future<void>.delayed(const Duration(milliseconds: 300));

          await bloc.close();
        }, (error, stackTrace) {
          blocError = error;
        });

        expect(
          blocError,
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains(
              '''An event handler completed but left pending subscriptions behind.''',
            ),
          ),
        );
      });

      test('forEach cancels subscriptions correctly', () async {
        const expectedStates = [0, 1, 2, 3, 4];
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(ForEach());

        await tick();

        controller
          ..add(0)
          ..add(1)
          ..add(2);

        await tick();

        bloc.add(ForEach());

        await tick();

        controller
          ..add(3)
          ..add(4);

        await bloc.close();
        expect(states, equals(expectedStates));
      });

      test(
          'forEach with onError handles errors emitted by stream '
          'and does not cancel the subscription', () async {
        const expectedStates = [1, 2, 3, -1, 4, 5, 6];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(ForEachOnError());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();

        controller
          ..addError(error)
          ..add(4)
          ..add(5)
          ..add(6);

        await tick();

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test('forEach with try/catch handles errors emitted by stream', () async {
        const expectedStates = [1, 2, 3, -1];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(ForEachTryCatch());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();

        controller.addError(error);

        await tick();

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test(
          'forEach with catchError '
          'handles errors emitted by stream', () async {
        const expectedStates = [1, 2, 3, -1];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(ForEachCatchError());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();

        controller.addError(error);

        await tick();

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test('forEach throws when stream emits error', () async {
        const expectedStates = [1, 2, 3];
        final error = Exception('oops');
        final states = <int>[];
        late final dynamic uncaughtError;

        await runZonedGuarded(
          () async {
            final controller = StreamController<int>.broadcast();
            final bloc = RestartableStreamBloc(controller.stream)
              ..stream.listen(states.add)
              ..add(ForEach());

            await tick();

            controller
              ..add(1)
              ..add(2)
              ..add(3);

            await tick();

            controller
              ..addError(error)
              ..add(3)
              ..add(4)
              ..add(5);

            await bloc.close();
          },
          (error, stackTrace) => uncaughtError = error,
        );
        expect(states, equals(expectedStates));
        expect(uncaughtError, equals(error));
      });

      test('unawaited onEach throws AssertionError', () async {
        late final Object blocError;
        await runZonedGuarded(() async {
          final controller = StreamController<int>.broadcast();
          final bloc = RestartableStreamBloc(controller.stream)
            ..add(UnawaitedOnEach());

          await bloc.close();
        }, (error, stackTrace) {
          blocError = error;
        });

        expect(
          blocError,
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains(
              '''An event handler completed but left pending subscriptions behind.''',
            ),
          ),
        );
      });

      test(
          'onEach with onError handles errors emitted by stream '
          'and does not cancel subscription', () async {
        const expectedStates = [1, 2, 3, -1, 4, 5, 6];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(OnEachOnError());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        controller
          ..addError(error)
          ..add(4)
          ..add(5)
          ..add(6);
        await tick();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test('onEach with try/catch handles errors emitted by stream', () async {
        const expectedStates = [1, 2, 3, -1];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(OnEachTryCatch());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        controller.addError(error);
        await tick();

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test(
          'onEach with try/catch handles errors '
          'emitted by stream and cancels delayed emits', () async {
        const expectedStates = [-1];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(OnEachTryCatchAbort());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3)
          ..addError(error);

        await tick();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test(
          'onEach with catchError '
          'handles errors emitted by stream', () async {
        const expectedStates = [1, 2, 3, -1];
        final error = Exception('oops');
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(OnEachCatchError());

        await tick();

        controller
          ..add(1)
          ..add(2)
          ..add(3);

        await tick();
        await Future<void>.delayed(const Duration(milliseconds: 300));

        controller.addError(error);
        await tick();

        expect(states, equals(expectedStates));

        await bloc.close();
      });

      test('onEach cancels subscriptions correctly', () async {
        const expectedStates = [3, 4];
        final states = <int>[];
        final controller = StreamController<int>.broadcast();
        final bloc = RestartableStreamBloc(controller.stream)
          ..stream.listen(states.add)
          ..add(OnEach());

        await tick();

        controller
          ..add(0)
          ..add(1)
          ..add(2);

        bloc.add(OnEach());
        await tick();

        controller
          ..add(3)
          ..add(4);

        await Future<void>.delayed(const Duration(milliseconds: 300));

        await bloc.close();
        expect(states, equals(expectedStates));
      });

      test('onEach throws when stream emits error', () async {
        const expectedStates = [1, 2, 3];
        final error = Exception('oops');
        final states = <int>[];
        late final dynamic uncaughtError;

        await runZonedGuarded(
          () async {
            final controller = StreamController<int>.broadcast();
            final bloc = RestartableStreamBloc(controller.stream)
              ..stream.listen(states.add)
              ..add(OnEach());

            await tick();

            controller
              ..add(1)
              ..add(2)
              ..add(3);

            await tick();
            await Future<void>.delayed(const Duration(milliseconds: 300));

            controller
              ..addError(error)
              ..add(4)
              ..add(5)
              ..add(6);

            await tick();
            await Future<void>.delayed(const Duration(milliseconds: 300));

            await bloc.close();
          },
          (error, stack) => uncaughtError = error,
        );

        expect(states, equals(expectedStates));
        expect(uncaughtError, equals(error));
      });
    });

    group('UnawaitedBloc', () {
      test(
          'throws AssertionError when emit is called '
          'after the event handler completed normally', () async {
        late final Object blocError;
        await runZonedGuarded(
          () async {
            final completer = Completer<void>();
            final bloc = UnawaitedBloc(completer.future)..add(UnawaitedEvent());

            await tick();

            completer.complete();

            await tick();

            await bloc.close();
          },
          (error, stackTrace) => blocError = error,
        );

        expect(
          blocError,
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains(
              'emit was called after an event handler completed normally.',
            ),
          ),
        );
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
          expect(error.toString(), equals('Exception: fatal exception'));
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
            // ignore: invalid_use_of_protected_member
          ).addError(expectedError, StackTrace.current);
        }, (Object error, StackTrace stackTrace) {
          expect(error, equals(expectedError));
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from on<E>', () {
        final exception = Exception('fatal exception');
        runZonedGuarded(() {
          Object? expectedError;
          StackTrace? expectedStacktrace;

          final onExceptionBloc = OnExceptionBloc(
            exception: exception,
            onErrorCallback: (Object error, StackTrace stackTrace) {
              expectedError = error;
              expectedStacktrace = stackTrace;
            },
          );

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
          expect(error, equals(exception));
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from onEvent', () {
        final exception = Exception('fatal exception');
        runZonedGuarded(() {
          OnEventErrorBloc(exception: exception)
            ..add(CounterEvent.increment)
            ..close();
        }, (Object error, StackTrace stackTrace) {
          expect(error, equals(exception));
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test(
          'add throws StateError and triggers onError '
          'when bloc is closed', () {
        Object? capturedError;
        StackTrace? capturedStacktrace;
        var didThrow = false;
        runZonedGuarded(() {
          final counterBloc = CounterBloc(
            onErrorCallback: (error, stackTrace) {
              capturedError = error;
              capturedStacktrace = stackTrace;
            },
          );

          expectLater(
            counterBloc.stream,
            emitsInOrder(<Matcher>[emitsDone]),
          );

          counterBloc
            ..close()
            ..add(CounterEvent.increment);
        }, (Object error, StackTrace stackTrace) {
          didThrow = true;
          expect(error, equals(capturedError));
          expect(stackTrace, equals(capturedStacktrace));
        });

        expect(didThrow, isTrue);
        expect(
          capturedError,
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot add new events after calling close',
          ),
        );
        expect(capturedStacktrace, isNotNull);
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

      test(
          'throws StateError and triggers onError '
          'when bloc is closed', () async {
        Object? capturedError;
        StackTrace? capturedStacktrace;

        final states = <int>[];
        final expectedStateError = isA<StateError>().having(
          (e) => e.message,
          'message',
          'Cannot emit new states after calling close',
        );

        final counterBloc = CounterBloc(
          onErrorCallback: (error, stackTrace) {
            capturedError = error;
            capturedStacktrace = stackTrace;
          },
        )..stream.listen(states.add);

        await counterBloc.close();

        expect(counterBloc.isClosed, isTrue);
        expect(counterBloc.state, equals(0));
        expect(states, isEmpty);
        expect(() => counterBloc.emit(1), throwsA(expectedStateError));
        expect(counterBloc.state, equals(0));
        expect(states, isEmpty);
        expect(capturedError, expectedStateError);
        expect(capturedStacktrace, isNotNull);
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

    group('isClosed', () {
      test('returns true after bloc is closed', () async {
        final bloc = CounterBloc();
        expect(bloc.isClosed, isFalse);
        await bloc.close();
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}

void unawaited(Future<void> future) {}
