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

      test('dispose does not emit new states over the state stream', () {
        final List<Matcher> expectedStates = [equals(''), emitsDone];

        expectLater(
          simpleBloc,
          emitsInOrder(expectedStates),
        );

        simpleBloc.dispose();
      });

      test('initialState returns correct value', () {
        expect(simpleBloc.initialState, '');
      });

      test('state returns correct value initially', () {
        expect(simpleBloc.state, '');
      });

      test('state should equal initial state before any events are dispatched',
          () async {
        final initialState = await simpleBloc.first;
        expect(initialState, simpleBloc.initialState);
      });

      test('should map single event to correct state', () {
        final List<String> expectedStates = ['', 'data'];

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

        simpleBloc.dispatch('event');
      });

      test('should map multiple events to correct states', () {
        final List<String> expectedStates = ['', 'data'];

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

        simpleBloc.dispatch('event1');
        simpleBloc.dispatch('event2');
        simpleBloc.dispatch('event3');
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

      test('dispose does not emit new states over the state stream', () {
        final List<Matcher> expectedStates = [
          equals(ComplexStateA()),
          emitsDone
        ];

        expectLater(
          complexBloc,
          emitsInOrder(expectedStates),
        );

        complexBloc.dispose();
      });

      test('initialState returns ComplexStateA', () {
        expect(complexBloc.initialState, ComplexStateA());
      });

      test('state returns correct value initially', () {
        expect(complexBloc.state, ComplexStateA());
      });

      test('state should equal initial state before any events are dispatched',
          () async {
        final initialState = await complexBloc.first;
        expect(initialState, complexBloc.initialState);
      });

      test('should map single event to correct state', () {
        final List<ComplexState> expectedStates = [
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

        complexBloc.dispatch(ComplexEventB());
      });

      test('should map multiple events to correct states', () async {
        final List<ComplexState> expectedStates = [
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

        complexBloc.dispatch(ComplexEventA());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.dispatch(ComplexEventB());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.dispatch(ComplexEventC());
        await Future<void>.delayed(Duration(milliseconds: 20));
        complexBloc.dispatch(ComplexEventD());
        await Future<void>.delayed(Duration(milliseconds: 200));
        complexBloc.dispatch(ComplexEventC());
        complexBloc.dispatch(ComplexEventA());
        await Future<void>.delayed(Duration(milliseconds: 120));
        complexBloc.dispatch(ComplexEventC());
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

      final OnEventCallback onEventCallback = (event) {
        events.add(event);
      };

      final OnTransitionCallback onTransitionCallback = (transition) {
        transitions.add(transition.toString());
      };

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

      test('state should equal initial state before any events are dispatched',
          () async {
        final initialState = await counterBloc.first;
        expect(initialState, counterBloc.initialState);
      });

      test('single Increment event updates state to 1', () {
        final List<int> expectedStates = [0, 1];
        final expectedTransitions = [
          'Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }'
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

        counterBloc.dispatch(CounterEvent.increment);
      });

      test('multiple Increment event updates state to 3', () {
        final List<int> expectedStates = [0, 1, 2, 3];
        final expectedTransitions = [
          'Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }',
          'Transition { currentState: 1, event: CounterEvent.increment, nextState: 2 }',
          'Transition { currentState: 2, event: CounterEvent.increment, nextState: 3 }',
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

        counterBloc.dispatch(CounterEvent.increment);
        counterBloc.dispatch(CounterEvent.increment);
        counterBloc.dispatch(CounterEvent.increment);
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

      test('dispose does not emit new states over the state stream', () {
        final List<Matcher> expectedStates = [
          equals(AsyncState.initial()),
          emitsDone
        ];

        expectLater(
          asyncBloc,
          emitsInOrder(expectedStates),
        );

        asyncBloc.dispose();
      });

      test(
          'dispose while events are pending does not emit new states or trigger onError',
          () {
        final List<Matcher> expectedStates = [
          equals(AsyncState.initial()),
          emitsDone
        ];

        expectLater(
          asyncBloc,
          emitsInOrder(expectedStates),
        );

        asyncBloc.dispatch(AsyncEvent());
        asyncBloc.dispose();

        verifyNever(delegate.onError(any, any, any));
      });

      test('initialState returns correct initial state', () {
        expect(asyncBloc.initialState, AsyncState.initial());
      });

      test('state returns correct value initially', () {
        expect(asyncBloc.state, AsyncState.initial());
      });

      test('state should equal initial state before any events are dispatched',
          () async {
        final initialState = await asyncBloc.first;
        expect(initialState, asyncBloc.initialState);
      });

      test('should map single event to correct state', () {
        final List<AsyncState> expectedStates = [
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

        asyncBloc.dispatch(AsyncEvent());
      });

      test('isBroadcast returns true', () {
        expect(asyncBloc.isBroadcast, isTrue);
      });
    });

    group('== operator', () {
      test('returns true for the same two CounterBlocs', () {
        final CounterBloc _blocA = CounterBloc();
        final CounterBloc _blocB = CounterBloc();

        expect(_blocA == _blocB, true);
      });

      test('returns false for the two different Blocs', () {
        final CounterBloc _blocA = CounterBloc();
        final ComplexBloc _blocB = ComplexBloc();

        expect(_blocA == _blocB, false);
      });
    });

    group('Exception', () {
      test('does not break stream', () {
        final List<int> expected = [0, -1];
        final CounterExceptionBloc _bloc = CounterExceptionBloc();

        expectLater(_bloc, emitsInOrder(expected));

        _bloc.dispatch(CounterEvent.increment);
        _bloc.dispatch(CounterEvent.decrement);
      });

      test('triggers onError from mapEventToState', () {
        final exception = Exception('fatal exception');
        Object expectedError;
        StackTrace expectedStacktrace;

        final OnExceptionBloc _bloc = OnExceptionBloc(
            exception: exception,
            onErrorCallback: (Object error, StackTrace stacktrace) {
              expectedError = error;
              expectedStacktrace = stacktrace;
            });

        expectLater(
          _bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(expectedError, exception);
          expect(expectedStacktrace, isNotNull);
        });

        _bloc.dispatch(CounterEvent.increment);
      });

      test('triggers onError from dispatch', () {
        Object capturedError;
        StackTrace capturedStacktrace;
        final CounterBloc _bloc = CounterBloc(
          onErrorCallback: (Object error, StackTrace stacktrace) {
            capturedError = error;
            capturedStacktrace = stacktrace;
          },
        );

        expectLater(
          _bloc,
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

        _bloc.dispose();
        _bloc.dispatch(CounterEvent.increment);
      });
    });

    group('Error', () {
      test('does not break stream', () {
        final List<int> expected = [0, -1];
        final CounterErrorBloc _bloc = CounterErrorBloc();

        expectLater(_bloc, emitsInOrder(expected));

        _bloc.dispatch(CounterEvent.increment);
        _bloc.dispatch(CounterEvent.decrement);
      });

      test('triggers onError from mapEventToState', () {
        final error = Error();
        Object expectedError;
        StackTrace expectedStacktrace;

        final OnErrorBloc _bloc = OnErrorBloc(
            error: error,
            onErrorCallback: (Object error, StackTrace stacktrace) {
              expectedError = error;
              expectedStacktrace = stacktrace;
            });

        expectLater(
          _bloc,
          emitsInOrder(<int>[0]),
        ).then((dynamic _) {
          expect(expectedError, error);
          expect(expectedStacktrace, isNotNull);
        });

        _bloc.dispatch(CounterEvent.increment);
      });
    });
  });
}
