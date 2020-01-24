import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import './helpers/helpers.dart';

class MockBlocDelegate extends Mock implements BlocDelegate {}

void main() {
  group('Bloc Tests', () {
    group('Simple Bloc', () {
      SimpleBloc simpleBloc;
      MockBlocDelegate delegate;

      setUp(() {
        simpleBloc = SimpleBloc();
        delegate = MockBlocDelegate();
        when(delegate.onTransition(any, any)).thenReturn(null);

        BlocSupervisor.delegate = delegate;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = [equals(''), emitsDone];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        );

        simpleBloc.close();
      });

      test('initialState returns correct value', () {
        expect(simpleBloc.initialState, '');
      });

      test('state returns correct value initially', () {
        expect(simpleBloc.state, '');
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await simpleBloc.first;
        expect(initialState, simpleBloc.initialState);
      });

      test('should map single event to correct state', () {
        final expectedStates = ['', 'data'];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            delegate.onTransition(
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
      });

      test('should map multiple events to correct states', () {
        final expectedStates = ['', 'data'];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            delegate.onTransition(
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
      });

      test('isBroadcast returns true', () {
        expect(simpleBloc.isBroadcast, isTrue);
      });
    });

    group('Complex Bloc', () {
      ComplexBloc complexBloc;
      MockBlocDelegate delegate;

      setUp(() {
        complexBloc = ComplexBloc();
        delegate = MockBlocDelegate();
        when(delegate.onTransition(any, any)).thenReturn(null);

        BlocSupervisor.delegate = delegate;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = [equals(ComplexStateA()), emitsDone];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        );

        complexBloc.close();
      });

      test('initialState returns ComplexStateA', () {
        expect(complexBloc.initialState, ComplexStateA());
      });

      test('state returns correct value initially', () {
        expect(complexBloc.state, ComplexStateA());
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await complexBloc.first;
        expect(initialState, complexBloc.initialState);
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          ComplexStateA(),
          ComplexStateB(),
        ];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            delegate.onTransition(
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

      test('isBroadcast returns true', () {
        expect(complexBloc.isBroadcast, isTrue);
      });
    });

    group('CounterBloc', () {
      CounterBloc counterBloc;
      MockBlocDelegate delegate;
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
        delegate = MockBlocDelegate();
        when(delegate.onTransition(any, any)).thenReturn(null);

        BlocSupervisor.delegate = delegate;
      });

      test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
        expect(events.isEmpty, true);
        expect(transitions.isEmpty, true);
      });

      test('state returns correct value initially', () {
        expect(counterBloc.state, 0);
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await counterBloc.first;
        expect(initialState, counterBloc.initialState);
      });

      test('single Increment event updates state to 1', () {
        final expectedStates = [0, 1];
        final expectedTransitions = [
          'Transition { currentState: 0, event: CounterEvent.increment, '
              'nextState: 1 }'
        ];

        expectLater(
          counterBloc,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expectLater(transitions, expectedTransitions);
          verify(
            delegate.onTransition(
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
      });

      test('multiple Increment event updates state to 3', () {
        final expectedStates = [0, 1, 2, 3];
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
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
          verify(
            delegate.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            delegate.onTransition(
              counterBloc,
              Transition<CounterEvent, int>(
                currentState: 1,
                event: CounterEvent.increment,
                nextState: 2,
              ),
            ),
          ).called(1);
          verify(
            delegate.onTransition(
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
      });

      test('isBroadcast returns true', () {
        expect(counterBloc.isBroadcast, isTrue);
      });
    });

    group('Async Bloc', () {
      AsyncBloc asyncBloc;
      MockBlocDelegate delegate;

      setUp(() {
        asyncBloc = AsyncBloc();
        delegate = MockBlocDelegate();
        when(delegate.onTransition(any, any)).thenReturn(null);

        BlocSupervisor.delegate = delegate;
      });

      test('close does not emit new states over the state stream', () {
        final expectedStates = [equals(AsyncState.initial()), emitsDone];

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

        verifyNever(delegate.onError(any, any, any));
      });

      test('initialState returns correct initial state', () {
        expect(asyncBloc.initialState, AsyncState.initial());
      });

      test('state returns correct value initially', () {
        expect(asyncBloc.state, AsyncState.initial());
      });

      test('state should equal initial state before any events are added',
          () async {
        final initialState = await asyncBloc.first;
        expect(initialState, asyncBloc.initialState);
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          AsyncState(isLoading: false, hasError: false, isSuccess: false),
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
        ];

        expectLater(
          asyncBloc,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            delegate.onTransition(
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
            delegate.onTransition(
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
      });

      test('isBroadcast returns true', () {
        expect(asyncBloc.isBroadcast, isTrue);
      });
    });

    group('Exception', () {
      test('does not break stream', () {
        final expected = [0, -1];
        final bloc = CounterExceptionBloc();

        expectLater(bloc, emitsInOrder(expected));

        bloc.add(CounterEvent.increment);
        bloc.add(CounterEvent.decrement);
      });

      test('triggers onError from mapEventToState', () {
        final exception = Exception('fatal exception');
        Object expectedError;
        StackTrace expectedStacktrace;

        final bloc = OnExceptionBloc(
            exception: exception,
            onErrorCallback: (error, stacktrace) {
              expectedError = error;
              expectedStacktrace = stacktrace;
            });

        expectLater(
          bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(expectedError, exception);
          expect(expectedStacktrace, isNotNull);
        });

        bloc.add(CounterEvent.increment);
      });

      test('triggers onError from add', () {
        Object capturedError;
        StackTrace capturedStacktrace;
        final bloc = CounterBloc(
          onErrorCallback: (error, stacktrace) {
            capturedError = error;
            capturedStacktrace = stacktrace;
          },
        );

        expectLater(
          bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(
            capturedError,
            isStateError,
          );
          expect(
            (capturedError as StateError).message,
            'Cannot add new events after calling close',
          );
          expect(capturedStacktrace, isNull);
        });

        bloc.close();
        bloc.add(CounterEvent.increment);
      });
    });

    group('Error', () {
      MockBlocDelegate delegate;

      setUp(() {
        delegate = MockBlocDelegate();
        BlocSupervisor.delegate = delegate;
      });

      test('does not break stream', () {
        final expected = [0, -1];
        final bloc = CounterErrorBloc();

        expectLater(bloc, emitsInOrder(expected));

        bloc.add(CounterEvent.increment);
        bloc.add(CounterEvent.decrement);
      });

      test('triggers onError from mapEventToState', () {
        final error = Error();
        Object expectedError;
        StackTrace expectedStacktrace;

        final bloc = OnErrorBloc(
          error: error,
          onErrorCallback: (error, stacktrace) {
            expectedError = error;
            expectedStacktrace = stacktrace;
          },
        );

        expectLater(
          bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(expectedError, error);
          expect(expectedStacktrace, isNotNull);
        });

        bloc.add(CounterEvent.increment);
      });

      test('triggers onError from onTransition', () {
        final error = Error();
        Object expectedError;
        StackTrace expectedStacktrace;

        final bloc = OnTransitionErrorBloc(
          error: error,
          onErrorCallback: (error, stacktrace) {
            expectedError = error;
            expectedStacktrace = stacktrace;
          },
        );

        expectLater(
          bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(expectedError, error);
          expect(expectedStacktrace, isNull);
          expect(bloc.state, 0);
        });
        bloc.add(CounterEvent.increment);
      });
    });
  });
}
