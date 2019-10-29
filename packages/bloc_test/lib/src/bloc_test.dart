import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// Creates a new [bloc]-specific test case with the given [description].
/// [blocTest] will handle asserting that the [bloc] emits the [expect]ed
/// states (in order) after the given event is [add]ed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the bloc stream before evaluating the [expect]ation.
///
/// [setUp] should be used to all [bloc] initialization and preparation
/// and must return the [bloc] under test.
///
/// [add] is an optional event which will be [add]ed to the [bloc].
///
/// [expect] is an `Iterable<State>` which we expect the [bloc]
/// under test to emit after the provided event is [add]ed.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0, 1] when CounterEvent.increment is added',
///   setUp: () => CounterBloc(),
///   add: CounterEvent.increment,
///   expect: [0, 1],
/// );
/// ```
///
/// [blocTest] can also be used to test the initial state of the [bloc]
/// by omitting [add].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0] when nothing is added',
///   setUp: () => CounterBloc(),
///   expect: [0],
/// );
/// ```
@isTest
void blocTest<B extends Bloc<Event, State>, Event, State>(
  String description, {
  @required B setUp(),
  @required Iterable<State> expect,
  Event add,
}) {
  test(description, () async {
    final bloc = setUp();
    if (add != null) {
      bloc.add(add);
    }
    await blocTestAssertion(bloc, expect);
  });
}

/// Internal test helper which asserts that a given [bloc]
/// emits the [expected] states in the exact order specified.
///
/// [blocTestAssertion] is called by [blocTest] and should not be used directly.
@visibleForTesting
Future<void> blocTestAssertion<B extends Bloc<dynamic, State>, State>(
  B bloc,
  Iterable<State> expected,
) async {
  var emitsDone = false;
  final states = <State>[];
  final subscription = bloc.listen(
    states.add,
    onDone: () => emitsDone = true,
  );
  await _tick();
  expect(states, expected);
  bloc.close();
  await _tick();
  expect(emitsDone, isTrue);
  expect(states, expected);
  subscription.cancel();
}

Future<void> _tick() => Future<void>.delayed(Duration(seconds: 0));
