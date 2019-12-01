import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

/// Similar to `emitsInOrder` but asserts that the provided [bloc]
/// emits **only** the [expected] states in the **exact** order in which
/// they were provided.
///
/// ```dart
/// test('emits [0, 1] when CounterEvent.increment is added', () async {
///   final bloc = CounterBloc();
///   bloc.add(CounterEvent.increment);
///   await emitsExactly(bloc, [0, 1]);
/// });
/// ```
///
/// [emitsExactly] also supports `Matchers` for states
/// which don't override `==` and `hashCode`.
///
/// ```dart
/// test('emits [StateA, StateB] when EventB is added', () async {
///   final bloc = MyBloc();
///   bloc.add(EventB());
///   await emitsExactly(bloc, [isA<StateA>(), isA<StateB>()]);
/// });
/// ```
Future<void> emitsExactly<B extends Bloc<dynamic, State>, State>(
  B bloc,
  Iterable expected,
) async {
  assert(bloc != null);
  final states = <State>[];
  final subscription = bloc.listen(states.add);
  await bloc.close();
  expect(states, expected);
  await subscription.cancel();
}
