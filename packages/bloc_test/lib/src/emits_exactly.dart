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
/// [skip] is an optional `int` which defaults to 0 and can be used to skip any
/// number of states.
///
/// ```dart
/// test('emits [2] when CounterEvent.increment is added twice', () async {
///   final bloc = CounterBloc();
///   bloc..add(CounterEvent.increment)..add(CounterEvent.increment);
///   await emitsExactly(bloc, [2], skip: 1);
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
Future<void> emitsExactly<B extends Bloc<Object, State>, State>(
  B bloc,
  Iterable expected, {
  Duration duration,
  int skip = 0,
}) async {
  assert(bloc != null);
  final states = <State>[];
  final subscription = bloc.skip(skip).listen(states.add);
  if (duration != null) await Future<void>.delayed(duration);
  await bloc.close();
  expect(states, expected);
  await subscription.cancel();
}
