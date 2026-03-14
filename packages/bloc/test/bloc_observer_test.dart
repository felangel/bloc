// ignore_for_file: invalid_use_of_protected_member
import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class _MockBlocObserver extends Mock implements BlocObserver {}

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

  group(BlocObserver, () {
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

  group(MultiBlocObserver, () {
    late MultiBlocObserver observer;
    late List<BlocObserver> observers;

    setUp(() {
      observers = [_MockBlocObserver(), _MockBlocObserver()];
      observer = MultiBlocObserver(observers: observers);
    });

    group('onCreate', () {
      test('notifies all registered observers', () {
        observer.onCreate(bloc);
        for (final observer in observers) {
          verify(() => observer.onCreate(bloc)).called(1);
        }
      });
    });

    group('onEvent', () {
      test('notifies all registered observers', () {
        observer.onEvent(bloc, event);
        for (final observer in observers) {
          verify(() => observer.onEvent(bloc, event)).called(1);
        }
      });
    });

    group('onChange', () {
      test('notifies all registered observers', () {
        observer.onChange(bloc, change);
        for (final observer in observers) {
          verify(() => observer.onChange(bloc, change)).called(1);
        }
      });
    });

    group('onTransition', () {
      test('notifies all registered observers', () {
        observer.onTransition(bloc, transition);
        for (final observer in observers) {
          verify(() => observer.onTransition(bloc, transition)).called(1);
        }
      });
    });

    group('onDone', () {
      test('notifies all registered observers', () {
        observer.onDone(bloc, event);
        for (final observer in observers) {
          verify(() => observer.onDone(bloc, event)).called(1);
        }
      });
    });

    group('onError', () {
      test('notifies all registered observers', () {
        observer.onError(bloc, error, stackTrace);
        for (final observer in observers) {
          verify(() => observer.onError(bloc, error, stackTrace)).called(1);
        }
      });
    });

    group('onClose', () {
      test('notifies all registered observers', () {
        observer.onClose(bloc);
        for (final observer in observers) {
          verify(() => observer.onClose(bloc)).called(1);
        }
      });
    });
  });
}
