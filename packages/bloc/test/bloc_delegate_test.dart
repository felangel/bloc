import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import './helpers/helpers.dart';

class MockBlocDelegate extends Mock implements BlocDelegate {}

void main() {
  group('onEvent', () {
    test('returns null on base delegate', () {
      BlocDelegate().onEvent(null, null);
    });

    test('is called when delegate is provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB(),
      ];
      BlocSupervisor.delegate = delegate;
      when(delegate.onEvent(any, any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verify(
          delegate.onEvent(
            complexBloc,
            ComplexEventB(),
          ),
        ).called(1);
      });

      complexBloc.dispatch(ComplexEventB());
    });

    test('is called when delegate is provided for multiple blocs', () {
      final delegate = MockBlocDelegate();
      final complexBlocA = ComplexBloc();
      final complexBlocB = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB()
      ];
      final List<ComplexState> expectedStateAfterEventC = [
        ComplexStateA(),
        ComplexStateC()
      ];
      BlocSupervisor.delegate = delegate;
      when(delegate.onEvent(any, any)).thenReturn(null);

      expectLater(
        complexBlocA.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verify(
          delegate.onEvent(
            complexBlocA,
            ComplexEventB(),
          ),
        ).called(1);
      });

      expectLater(
        complexBlocB.state,
        emitsInOrder(expectedStateAfterEventC),
      ).then((dynamic _) {
        verify(
          delegate.onEvent(
            complexBlocB,
            ComplexEventC(),
          ),
        ).called(1);
      });

      complexBlocA.dispatch(ComplexEventB());
      complexBlocB.dispatch(ComplexEventC());
    });

    test('is not called when delegate is not provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB()
      ];
      BlocSupervisor.delegate = null;
      when(delegate.onEvent(any, any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verifyNever(
          delegate.onEvent(
            complexBloc,
            ComplexEventB(),
          ),
        );
      });

      complexBloc.dispatch(ComplexEventB());
    });
  });
  group('onTransition', () {
    test('returns null on base delegate', () {
      BlocDelegate().onTransition(null, null);
    });

    test('is called when delegate is provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB(),
      ];
      BlocSupervisor.delegate = delegate;
      when(delegate.onTransition(any, any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
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
      });

      complexBloc.dispatch(ComplexEventB());
    });

    test('is called when delegate is provided for multiple blocs', () {
      final delegate = MockBlocDelegate();
      final complexBlocA = ComplexBloc();
      final complexBlocB = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB()
      ];
      final List<ComplexState> expectedStateAfterEventC = [
        ComplexStateA(),
        ComplexStateC()
      ];
      BlocSupervisor.delegate = delegate;
      when(delegate.onTransition(any, any)).thenReturn(null);

      expectLater(
        complexBlocA.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verify(
          delegate.onTransition(
            complexBlocA,
            Transition<ComplexEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: ComplexEventB(),
              nextState: ComplexStateB(),
            ),
          ),
        ).called(1);
      });

      expectLater(
        complexBlocB.state,
        emitsInOrder(expectedStateAfterEventC),
      ).then((dynamic _) {
        verify(
          delegate.onTransition(
            complexBlocB,
            Transition<ComplexEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: ComplexEventC(),
              nextState: ComplexStateC(),
            ),
          ),
        ).called(1);
      });

      complexBlocA.dispatch(ComplexEventB());
      complexBlocB.dispatch(ComplexEventC());
    });

    test('is not called when delegate is not provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [
        ComplexStateA(),
        ComplexStateB()
      ];
      BlocSupervisor.delegate = null;
      when(delegate.onTransition(any, any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verifyNever(
          delegate.onTransition(
            complexBloc,
            Transition<ComplexEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: ComplexEventB(),
              nextState: ComplexStateB(),
            ),
          ),
        );
      });

      complexBloc.dispatch(ComplexEventB());
    });
  });

  group('onError', () {
    test('returns null on base delegate', () {
      BlocDelegate().onError(null, null, null);
    });

    test('is called on bloc exception', () {
      bool errorHandled = false;
      Bloc blocWithError;

      final delegate = MockBlocDelegate();
      final CounterExceptionBloc _bloc = CounterExceptionBloc();
      BlocSupervisor.delegate = delegate;

      when(delegate.onError(any, any, any)).thenAnswer((Invocation invocation) {
        blocWithError = invocation.positionalArguments[0] as Bloc;
        errorHandled = true;
      });

      expectLater(_bloc.state, emitsInOrder(<int>[0])).then((dynamic _) {
        expect(errorHandled, isTrue);
        expect(blocWithError, _bloc);
      });

      _bloc.dispatch(CounterEvent.increment);
    });
  });
}
