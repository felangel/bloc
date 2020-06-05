import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

/// Similar to `emitsInOrder` but asserts that the provided [bloc]
/// emits **only** the [expected] states in the **exact** order in which
/// they were provided.
///
/// ```dart
/// test('emits [1] when CounterEvent.increment is added', () async {
///   final bloc = CounterBloc();
///   bloc.add(CounterEvent.increment);
///   await emitsExactly(bloc, [1]);
/// });
/// ```
///
/// [emitsExactly] also supports `Matchers` for states
/// which don't override `==` and `hashCode`.
///
/// ```dart
/// test('emits [StateB] when EventB is added', () async {
///   final bloc = MyBloc();
///   bloc.add(EventB());
///   await emitsExactly(bloc, [isA<StateB>()]);
/// });
/// ```
///
/// [skip] is an optional `int` which defaults to 1 and can be used to skip any
/// number of states. The default behavior skips the `initialState` of the bloc
/// but can be overridden to include the `initialState` by setting it to 0.
///
/// ```dart
/// test('emits [0, 1] when CounterEvent.increment is added', () async {
///   final bloc = CounterBloc();
///   bloc.add(CounterEvent.increment);
///   await emitsExactly(bloc, [0, 1], skip: 0);
/// });
/// ```
///
/// [emitsExactly] also takes an optional [duration] which is useful in cases
/// where the [bloc] is using `debounceTime` or other similar operators.
///
/// ```dart
/// test('emits [1] when CounterEvent.increment is added', () async {
///   final bloc = CounterBloc();
///   bloc.add(CounterEvent.increment);
///   await emitsExactly(
///     bloc,
///     [1],
///     duration: const Duration(milliseconds: 300),
///   );
/// });
/// ```
Future<void> emitsExactly<B extends Bloc<dynamic, State>, State>(
  B bloc,
  Iterable expected, {
  Duration duration,
  int skip = 1,
}) async {
  assert(bloc != null);
  final states = <State>[];
  final subscription = bloc.skip(skip).listen(states.add);
  if (duration != null) await Future.delayed(duration);
  await bloc.close();
  expect(states, expected);
  await subscription.cancel();
}
