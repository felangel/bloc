import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

/// {@template mock_bloc}
/// Extend or mixin this class to mark the implementation as a [MockBloc].
///
/// A mocked bloc/cubit implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when] and `whenListen`.
///
/// _**Note**: It is critical to explicitly provide the bloc event and state
/// types when extending [MockBloc]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterBloc extends MockBloc<CounterEvent, int>
///   implements CounterBloc {}
/// class MockCounterCubit extends MockBloc<Null, int>
///   implements CounterCubit {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterBloc extends MockBloc implements CounterBloc {}
/// class MockCounterCubit extends MockBloc implements CounterCubit {}
/// ```
/// {@endtemplate}
class MockBloc<E, S> extends Mock implements Bloc<E, S> {
  /// {@macro mock_bloc}
  MockBloc() {
    when(this).calls(#add).thenReturn(null);
    when(this).calls(#isBroadcast).thenReturn(true);
    when(this).calls(#skip).thenAnswer((_) => Stream<S>.empty());
    when(this)
        .calls(#listen)
        .thenAnswer((_) => Stream<S>.empty().listen((_) {}));
  }
}
