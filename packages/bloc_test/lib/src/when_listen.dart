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
/// when `counterBloc.stream.listen` is called.
///
/// ```dart
/// whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
/// ```
///
/// Assert that the `counterBloc` state `Stream` is the canned `Stream`.
///
/// ```dart
/// await expectLater(
///   counterBloc.stream,
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
void whenListen<State>(
  BlocBase<State> bloc,
  Stream<State> stream, {
  State? initialState,
}) {
  final broadcastStream = stream.asBroadcastStream();

  if (initialState != null) {
    when(() => bloc.state).thenReturn(initialState);
  }

  when(() => bloc.stream).thenAnswer(
    (_) => broadcastStream.map((state) {
      when(() => bloc.state).thenReturn(state);
      return state;
    }),
  );
}
