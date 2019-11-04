import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// Creates a new [bloc]-specific test case with the given [description].
/// [blocTest] will handle asserting that the [bloc] emits the [expect]ed
/// states (in order) after [act] is executed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the [bloc] stream before evaluating the [expect]ation.
///
/// [build] should be used for all [bloc] initialization and preparation
/// and must return the [bloc] under test.
///
/// [act] is an optional callback which will be invoked with the [bloc] under test
/// and should be used to `add` events to the bloc.
///
/// [expect] is an `Iterable<State>` which the [bloc]
/// under test is expected to emit after [act] is executed.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0, 1] when CounterEvent.increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: [0, 1],
/// );
/// ```
///
/// [blocTest] can also be used to test the initial state of the [bloc]
/// by omitting [act].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0] when nothing is added',
///   build: () => CounterBloc(),
///   expect: [0],
/// );
/// ```
@isTest
void blocTest<B extends Bloc<Event, State>, Event, State>(
  String description, {
  @required B build(),
  @required Iterable<State> expect,
  Future<void> Function(B bloc) act,
}) {
  test(description, () async {
    final bloc = build();
    await act?.call(bloc);
    await emitsExactly(bloc, expect);
  });
}
