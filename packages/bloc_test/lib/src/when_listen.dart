import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';

/// Creates a stub response for the `listen` method on a [bloc].
/// Use [whenListen] if you want to return a canned `Stream` of states
/// for a [bloc] instance.
///
/// [whenListen] also handles stubbing the `state` of the bloc to stay
/// in sync with the emitted state.
///
/// Return a canned state stream of `[0, 1, 2, 3]`
/// when `counterBloc.listen` is called.
///
/// ```dart
/// whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
/// ```
///
/// Assert that the `counterBloc` state `Stream`
/// is the canned `Stream`.
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
void whenListen<Event, State>(
  Bloc<Event, State> bloc,
  Stream<State> stream,
) {
  StreamSubscription<State> subscription;
  final broadcastStream = stream.asBroadcastStream();
  subscription = broadcastStream.listen(
    (state) => when(bloc.state).thenReturn(state),
    onDone: () => subscription?.cancel(),
  );
  when(bloc.skip(any)).thenAnswer(
    (invocation) => broadcastStream.skip(
      invocation.positionalArguments.first as int,
    ),
  );

  when(bloc.listen(
    any,
    onError: captureAnyNamed('onError'),
    onDone: captureAnyNamed('onDone'),
    cancelOnError: captureAnyNamed('cancelOnError'),
  )).thenAnswer((invocation) {
    return broadcastStream.listen(
      invocation.positionalArguments.first as Function(State),
      onError: invocation.namedArguments[Symbol('onError')] as Function,
      onDone: invocation.namedArguments[Symbol('onDone')] as void Function(),
      cancelOnError: invocation.namedArguments[Symbol('cancelOnError')] as bool,
    );
  });
}
