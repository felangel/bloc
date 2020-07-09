import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// Creates a new `cubit`-specific test case with the given [description].
/// [cubitTest] will handle asserting that the `cubit` emits the [expect]ed
/// states (in order) after [act] is executed.
/// [cubitTest] also handles ensuring that no additional states are emitted
/// by closing the `cubit` stream before evaluating the [expect]ation.
///
/// [build] should be used for all `cubit` initialization and preparation
/// and must return the `cubit` under test as a `Future`.
///
/// [act] is an optional callback which will be invoked with the `cubit` under
/// test and should be used to interact with the `cubit`.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// The default value is 1 which skips the `initialState` of the cubit.
/// [skip] can be overridden to include the `initialState` by setting it to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `cubit` under test such as `debounceTime`.
///
/// [expect] is an optional `Iterable` of matchers which the `cubit`
/// under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the `cubit` returned by [build].
///
///
/// ```dart
/// cubitTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () async => CounterCubit(),
///   act: (cubit) async => cubit.increment(),
///   expect: [1],
/// );
/// ```
///
/// [cubitTest] can also be used to test the initial state of the `cubit`
/// by omitting [act].
///
/// ```dart
/// cubitTest(
///   'CounterCubit emits [] when nothing is called',
///   build: () async => CounterCubit(),
///   expect: [],
/// );
/// ```
///
/// [cubitTest] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// The default value is 1 which skips the initial state of the cubit.
/// [skip] can be overridden to include the initial state` by setting it to 0.
///
/// ```dart
/// cubitTest(
///   'CounterCubit emits [0, 1] when increment is called',
///   build: () async => CounterCubit(),
///   act: (cubit) async => cubit.increment(),
///   skip: 0,
///   expect: [0, 1],
/// );
/// ```
///
/// [cubitTest] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// cubitTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () async => CounterCubit(),
///   act: (cubit) async => cubit.increment(),
///   wait: const Duration(milliseconds: 300),
///   expect: [1],
/// );
/// ```
///
/// [cubitTest] can also be used to [verify] internal cubit functionality.
///
/// ```dart
/// cubitTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () async => CounterCubit(),
///   act: (cubit) async => cubit.increment(),
///   expect: [1],
///   verify: (_) async {
///     verify(repository.someMethod(any)).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [cubitTest] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// cubitTest(
///  'emits [StateB] when emitB is called',
///  build: () async => MyCubit(),
///  act: (cubit) async => cubit.emitB(),
///  expect: [isA<StateB>()],
/// );
/// ```
@isTest
void cubitTest<C extends CubitStream<State>, State>(
  String description, {
  @required Future<C> Function() build,
  Future<void> Function(C cubit) act,
  Duration wait,
  int skip = 1,
  Iterable expect,
  Future<void> Function(C cubit) verify,
}) {
  test.test(description, () async {
    await runZoned(
      () async {
        final cubit = await build();
        final states = <State>[];
        final subscription = cubit.skip(skip).listen(states.add);
        await Future<void>.delayed(Duration.zero);
        await act?.call(cubit);
        if (wait != null) await Future<void>.delayed(wait);
        await cubit.close();
        if (expect != null) test.expect(states, expect);
        await subscription.cancel();
        await verify?.call(cubit);
      },
    );
  });
}
