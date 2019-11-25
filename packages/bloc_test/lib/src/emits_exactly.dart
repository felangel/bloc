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
Future<void> emitsExactly<B extends Bloc<dynamic, State>, State>(
  B bloc,
  Iterable<State> expected,
) async {
  assert(bloc != null);
  final states = <State>[];
  final subscription = bloc.listen(states.add);
  await bloc.close();
  expect(states, expected);
  subscription.cancel();
}
