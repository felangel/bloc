import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';

/// Creates a stub response for the `listen` method on a [cubit].
/// Use [whenListen] if you want to return a canned `Stream` of states
/// for a [cubit] instance.
///
/// [whenListen] also handles stubbing the `state` of the [cubit] to stay
/// in sync with the emitted state.
///
/// Return a canned state stream of `[0, 1, 2, 3]`
/// when `counterBloc.listen` is called.
///
/// ```dart
/// whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
/// ```
///
/// Assert that the `counterBloc` state `Stream` is the canned `Stream`.
///
/// ```dart
/// await expectLater(
///   counterBloc,
///   emitsInOrder(
///     <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
///   )
/// );
/// expect(counterBloc.state, equals(3));
/// ```
void whenListen<State>(
  Bloc<Object, State> bloc,
  Stream<State> stream,
) {
  final broadcastStream = stream.asBroadcastStream();
  StreamSubscription<State> subscription;
  when(bloc.isBroadcast).thenReturn(true);
  when(bloc.skip(any)).thenAnswer(
    (invocation) {
      final stream = broadcastStream.skip(
        invocation.positionalArguments.first as int,
      );
      subscription?.cancel();
      subscription = stream.listen(
        (state) => when(bloc.state).thenReturn(state),
        onDone: () => subscription?.cancel(),
      );
      return stream;
    },
  );

  when(bloc.listen(
    any,
    onError: captureAnyNamed('onError'),
    onDone: captureAnyNamed('onDone'),
    cancelOnError: captureAnyNamed('cancelOnError'),
  )).thenAnswer((invocation) {
    return broadcastStream.listen(
      (state) {
        when(bloc.state).thenReturn(state);
        (invocation.positionalArguments.first as Function(State)).call(state);
      },
      onError: invocation.namedArguments[const Symbol('onError')] as Function,
      onDone:
          invocation.namedArguments[const Symbol('onDone')] as void Function(),
      cancelOnError:
          invocation.namedArguments[const Symbol('cancelOnError')] as bool,
    );
  });
}
