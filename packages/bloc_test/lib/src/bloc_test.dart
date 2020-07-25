import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// Creates a new `cubit`-specific test case with the given [description].
/// [blocTest] will handle asserting that the `cubit` emits the [expect]ed
/// states (in order) after [act] is executed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the `cubit` stream before evaluating the [expect]ation.
///
/// [build] should be used for all `cubit` initialization and preparation
/// and must return the `cubit` under test.
///
/// [act] is an optional callback which will be invoked with the `cubit` under
/// test and should be used to interact with the `cubit`.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
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
/// blocTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () => CounterCubit(),
///   act: (cubit) => cubit.increment(),
///   expect: [1],
/// );
/// ```
///
/// [blocTest] can also be used to test the initial state of the `cubit`
/// by omitting [act].
///
/// ```dart
/// blocTest(
///   'CounterCubit emits [] when nothing is called',
///   build: () => CounterCubit(),
///   expect: [],
/// );
/// ```
///
/// [blocTest] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// [skip] defaults to 0.
///
/// ```dart
/// blocTest(
///   'CounterCubit emits [2] when increment is called twice',
///   build: () => CounterCubit(),
///   act: (cubit) {
///     cubit
///       ..increment()
///       ..increment();
///   },
///   skip: 1,
///   expect: [2],
/// );
/// ```
///
/// [blocTest] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// blocTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () => CounterCubit(),
///   act: (cubit) => cubit.increment(),
///   wait: const Duration(milliseconds: 300),
///   expect: [1],
/// );
/// ```
///
/// [blocTest] can also be used to [verify] internal cubit functionality.
///
/// ```dart
/// blocTest(
///   'CounterCubit emits [1] when increment is called',
///   build: () => CounterCubit(),
///   act: (cubit) => cubit.increment(),
///   expect: [1],
///   verify: (_) {
///     verify(repository.someMethod(any)).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [blocTest] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// blocTest(
///  'emits [StateB] when emitB is called',
///  build: () => MyCubit(),
///  act: (cubit) => cubit.emitB(),
///  expect: [isA<StateB>()],
/// );
/// ```
@isTest
void blocTest<C extends Cubit<State>, State>(
  String description, {
  @required C Function() build,
  Function(C cubit) act,
  Duration wait,
  int skip = 0,
  Iterable expect,
  Function(C cubit) verify,
  Iterable errors,
}) {
  test.test(description, () async {
    final unhandledErrors = <Object>[];
    await runZoned(
      () async {
        final states = <State>[];
        final cubit = build();
        final subscription = cubit.skip(skip).listen(states.add);
        await act?.call(cubit);
        if (wait != null) await Future<void>.delayed(wait);
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
        if (expect != null) test.expect(states, expect);
        await subscription.cancel();
        await verify?.call(cubit);
      },
      onError: (Object error) {
        if (error is CubitUnhandledErrorException) {
          unhandledErrors.add(error.error);
        } else {
          // ignore: only_throw_errors
          throw error;
        }
      },
    );
    if (errors != null) test.expect(unhandledErrors, errors);
  });
}
