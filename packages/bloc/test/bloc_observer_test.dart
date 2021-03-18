import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

void main() {
  final bloc = CounterBloc();
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
        BlocObserver().onCreate(bloc);
      });
    });

    group('onEvent', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        BlocObserver().onEvent(bloc, event);
      });
    });

    group('onChange', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        BlocObserver().onChange(bloc, change);
      });
    });

    group('onTransition', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        BlocObserver().onTransition(bloc, transition);
      });
    });

    group('onError', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        BlocObserver().onError(bloc, event, StackTrace.current);
      });
    });

    group('onClose', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        BlocObserver().onClose(bloc);
      });
    });
  });
}
