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
///
/// [emitsExactly] also takes an optional [duration] which is useful in cases
/// where the [bloc] is using `debounceTime` or other similar operators.
///
/// ```dart
/// test('emits [0, 1] when CounterEvent.increment is added', () async {
///   final bloc = CounterBloc();
///   bloc.add(CounterEvent.increment);
///   await emitsExactly(
///     bloc,
///     [0, 1],
///     duration: const Duration(milliseconds: 300),
///   );
/// });
/// ```
Future<void> emitsExactly<B extends Bloc<dynamic, State>, State>(
  B bloc,
  Iterable expected, {
  Duration duration,
}) async {
  assert(bloc != null);
  final states = <State>[];
  final subscription = bloc.listen(states.add);
  if (duration != null) await Future.delayed(duration);
  await bloc.close();
  expect(states, expected);
  await subscription.cancel();
}
