import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Creates a stub response for the `listen` method on a [bloc].
/// Use [whenListen] if you want to return a canned `Stream` of states
/// for a [bloc] instance.
///
/// [whenListen] also handles stubbing the `state` of the [bloc] to stay
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
///
/// Optionally provide an [initialState] to stub the state of the [bloc]
/// before any subscriptions.
///
/// ```dart
/// whenListen(
///   counterBloc,
///   Stream.fromIterable([0, 1, 2, 3]),
///   initialState: 0,
/// );
///
/// expect(counterBloc.state, equals(0));
/// ```
void whenListen<Event, State>(
  Bloc<Event, State> bloc,
  Stream<State> stream, {
  State? initialState,
}) {
  final broadcastStream = stream.asBroadcastStream();
  StreamSubscription<State>? subscription;
  when(bloc).calls(#state).thenReturn(initialState);
  when(bloc).calls(#isBroadcast).thenReturn(true);
  when(bloc).calls(#skip).thenAnswer(
    (invocation) {
      final stream = broadcastStream.skip(
        invocation.positionalArguments.first as int,
      );
      subscription?.cancel();
      subscription = stream.listen(
        (state) => when(bloc).calls(#state).thenReturn(state),
        onDone: () => subscription?.cancel(),
      );
      return stream;
    },
  );

  when(bloc).calls(#listen).thenAnswer((invocation) {
    return broadcastStream.listen(
      (state) {
        when(bloc).calls(#state).thenReturn(state);
        (invocation.positionalArguments.first as Function(State)).call(state);
      },
      onError: invocation.namedArguments[#onError] as Function?,
      onDone: invocation.namedArguments[#onDone] as void Function()?,
      cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
    );
  });
}
