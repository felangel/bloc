import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

/// {@template mock_bloc}
/// Extend or mixin this class to mark the implementation as a [MockBloc].
///
/// A mocked bloc implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when] and `whenListen`.
///
/// _**Note**: It is critical to explicitly provide the event and state
/// types when extending [MockBloc]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterBloc extends MockBloc<CounterEvent, int>
///   implements CounterBloc {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterBloc extends MockBloc implements CounterBloc {}
/// ```
/// {@endtemplate}
class MockBloc<E, S> extends Mock implements Bloc<E, S> {
  /// {@macro mock_bloc}
  MockBloc() {
    registerFallbackValue<void Function(S)>((S _) {});
    registerFallbackValue<void Function()>(() {});
    when(
      () => listen(
        any(),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      return Stream<S>.empty().listen(
        invocation.positionalArguments.first as void Function(S data),
        onError: invocation.namedArguments[#onError] as Function?,
        onDone: invocation.namedArguments[#onDone] as void Function()?,
        cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
      );
    });
    when(() => isBroadcast).thenReturn(true);
    // ignore: unnecessary_lambdas
    when(() => close()).thenAnswer((_) => Future<void>.value());
    when(() => mapEventToState(any())).thenAnswer((_) => Stream<S>.empty());
    when(() => add(any())).thenReturn(null);
    when(() => emit(any())).thenReturn(null);
  }
}

/// {@template mock_cubit}
/// Extend or mixin this class to mark the implementation as a [MockCubit].
///
/// A mocked cubit implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when] and `whenListen`.
///
/// _**Note**: It is critical to explicitly provide the state
/// types when extending [MockCubit]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterCubit extends MockCubit<int>
///   implements CounterCubit {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterCubit extends MockBloc implements CounterCubit {}
/// ```
/// {@endtemplate}
class MockCubit<S> extends MockBloc<Null, S> implements Cubit<S> {}
