// ignore_for_file: invalid_use_of_protected_member
import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class DefaultBlocObserver extends BlocObserver {
  const DefaultBlocObserver();
}

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
        const DefaultBlocObserver().onCreate(bloc);
      });
    });

    group('onEvent', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onEvent(bloc, event);
      });
    });

    group('onChange', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onChange(bloc, change);
      });
    });

    group('onTransition', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onTransition(bloc, transition);
      });
    });

    group('onDone', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onDone(bloc, event);
      });
    });

    group('onError', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onError(bloc, error, stackTrace);
      });
    });

    group('onClose', () {
      test('does nothing by default', () {
        const DefaultBlocObserver().onClose(bloc);
      });
    });
  });
}
