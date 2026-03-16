import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'blocs/counter_bloc.dart';
import 'blocs/exception_counter_bloc.dart';

class _MockBlocObserver extends Mock implements BlocObserver {}

void main() {
  group('BlocObserver', () {
    late BlocObserver blocObserver;

    setUp(() {
      blocObserver = _MockBlocObserver();
      final previousObserver = Bloc.observer;
      addTearDown(() => Bloc.observer = previousObserver);
      Bloc.observer = blocObserver;
    });

    blocTest<CounterBloc, int>(
      'calls onCreate',
      build: () => CounterBloc(),
      verify: (bloc) {
        // ignore: invalid_use_of_protected_member
        verify(() => blocObserver.onCreate(bloc)).called(1);
      },
    );

    blocTest<CounterBloc, int>(
      'calls onEvent',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      verify: (bloc) {
        verify(
          // ignore: invalid_use_of_protected_member
          () => blocObserver.onEvent(bloc, CounterEvent.increment),
        ).called(1);
      },
    );

    blocTest<CounterBloc, int>(
      'calls onChange',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      verify: (bloc) {
        const change = Change<int>(currentState: 0, nextState: 1);
        // ignore: invalid_use_of_protected_member
        verify(() => blocObserver.onChange(bloc, change)).called(1);
      },
    );

    blocTest<CounterBloc, int>(
      'calls onTransition',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      verify: (bloc) {
        const transition = Transition<CounterEvent, int>(
          event: CounterEvent.increment,
          currentState: 0,
          nextState: 1,
        );
        // ignore: invalid_use_of_protected_member
        verify(() => blocObserver.onTransition(bloc, transition)).called(1);
      },
    );

    blocTest<ExceptionCounterBloc, int>(
      'calls onError',
      build: () => ExceptionCounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      setUp: () {
        registerFallbackValue(StackTrace.empty);
      },
      verify: (bloc) {
        verify(
          // ignore: invalid_use_of_protected_member
          () => blocObserver.onError(
            bloc,
            ExceptionCounterBlocException(),
            any(),
          ),
        ).called(1);
      },
      errors: () => containsOnce(isA<ExceptionCounterBlocException>()),
    );

    blocTest<CounterBloc, int>(
      'calls onDone',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      verify: (bloc) {
        verify(
          // ignore: invalid_use_of_protected_member
          () => blocObserver.onDone(bloc, CounterEvent.increment),
        ).called(1);
      },
    );

    blocTest<CounterBloc, int>(
      'calls onClose',
      build: () => CounterBloc(),
      verify: (bloc) {
        // ignore: invalid_use_of_protected_member
        verify(() => blocObserver.onClose(bloc)).called(1);
      },
    );
  });
}
