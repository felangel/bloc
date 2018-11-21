import 'package:test/test.dart';
import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';

import './helpers/helpers.dart';

class MockBlocDelegate extends Mock implements BlocDelegate {}

void main() {
  group('onTransition', () {
    test('is called when delegate is provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [ComplexStateB()];
      BlocSupervisor().delegate = delegate;
      when(delegate.onTransition(any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verify(
          delegate.onTransition(
            Transition<BlocEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: EventB(),
              nextState: ComplexStateB(),
            ),
          ),
        ).called(1);
      });

      complexBloc.dispatch(EventB());
    });

    test('is called when delegate is provided for multiple blocs', () {
      final delegate = MockBlocDelegate();
      final complexBlocA = ComplexBloc();
      final complexBlocB = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [ComplexStateB()];
      final List<ComplexState> expectedStateAfterEventC = [ComplexStateC()];
      BlocSupervisor().delegate = delegate;
      when(delegate.onTransition(any)).thenReturn(null);

      expectLater(
        complexBlocA.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verify(
          delegate.onTransition(
            Transition<BlocEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: EventB(),
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
            Transition<BlocEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: EventC(),
              nextState: ComplexStateC(),
            ),
          ),
        ).called(1);
      });

      complexBlocA.dispatch(EventB());
      complexBlocB.dispatch(EventC());
    });

    test('is not called when delegate is not provided', () {
      final delegate = MockBlocDelegate();
      final complexBloc = ComplexBloc();
      final List<ComplexState> expectedStateAfterEventB = [ComplexStateB()];
      BlocSupervisor().delegate = null;
      when(delegate.onTransition(any)).thenReturn(null);

      expectLater(
        complexBloc.state,
        emitsInOrder(expectedStateAfterEventB),
      ).then((dynamic _) {
        verifyNever(
          delegate.onTransition(
            Transition<BlocEvent, ComplexState>(
              currentState: ComplexStateA(),
              event: EventB(),
              nextState: ComplexStateB(),
            ),
          ),
        );
      });

      complexBloc.dispatch(EventB());
    });
  });
}
