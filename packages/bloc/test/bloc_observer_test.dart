import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class DefaultBlocObserver extends BlocObserver {}

void main() {
  final bloc = CounterBloc();
  final error = Exception();
  const stackTrace = StackTrace.empty;
  const event = CounterEvent.increment;
  const change = Change(currentState: 0, nextState: 1);
  const transition = Transition(
    currentState: 0,
    event: CounterEvent.increment,
    nextState: 1,
  );
  group('BlocObserver', () {
    group('onCreate', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onCreate(bloc);
      });
    });

    group('onEvent', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onEvent(bloc, event);
      });
    });

    group('onChange', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onChange(bloc, change);
      });
    });

    group('onTransition', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onTransition(bloc, transition);
      });
    });

    group('onError', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onError(bloc, error, stackTrace);
      });
    });

    group('onClose', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        DefaultBlocObserver().onClose(bloc);
      });
    });
  });
}
