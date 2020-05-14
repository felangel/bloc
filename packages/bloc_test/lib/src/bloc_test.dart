import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// Creates a new [bloc]-specific test case with the given [description].
/// [blocTest] will handle asserting that the [bloc] emits the [expect]ed
/// states (in order) after [act] is executed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the [bloc] stream before evaluating the [expect]ation.
///
/// [build] should be used for all [bloc] initialization and preparation
/// and must return the [bloc] under test as a `Future`.
///
/// [act] is an optional callback which will be invoked with the [bloc] under
/// test and should be used to `add` events to the [bloc].
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// The default value is 1 which skips the `initialState` of the bloc.
/// [skip] can be overridden to include the `initialState` by setting it to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the [bloc] under test such as `debounceTime`.
///
/// [expect] is an optional `Iterable` of matchers which the [bloc]
/// under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the [bloc] returned by [build].
///
/// [errors] is an optional `Iterable` of error matchers which the [bloc]
/// under test is expected to have thrown after [act] is executed.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when CounterEvent.increment is added',
///   build: () async => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: [1],
/// );
/// ```
///
/// [blocTest] can also be used to test the initial state of the [bloc]
/// by omitting [act].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [] when nothing is added',
///   build: () async => CounterBloc(),
///   expect: [],
/// );
/// ```
///
/// [blocTest] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// The default value is 1 which skips the `initialState` of the bloc.
/// [skip] can be overridden to include the `initialState` by setting it to 0.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [0, 1] when CounterEvent.increment is added',
///   build: () async => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   skip: 0,
///   expect: [0, 1],
/// );
/// ```
///
/// [blocTest] can also be used to wait for async operations like `debounceTime`
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when CounterEvent.increment is added',
///   build: () async => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   wait: const Duration(milliseconds: 300),
///   expect: [1],
/// );
/// ```
///
/// [blocTest] can also be used to [verify] internal bloc functionality.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when CounterEvent.increment is added',
///   build: () async => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: [1],
///   verify: (_) async {
///     verify(repository.someMethod(any)).called(1);
///   }
/// );
/// ```
/// `blocTest` can also be used to expect that exceptions have been thrown.
///
/// ```dart
/// blocTest(
///   'CounterBloc throws Exception when null is added',
///   build: () async => CounterBloc(),
///   act: (bloc) => bloc.add(null),
///   errors: [
///     isA<Exception>(),
///   ]
/// );
/// ```
///
/// **Note:** when using [blocTest] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// blocTest(
///  'emits [StateB] when MyEvent is added',
///  build: () async => MyBloc(),
///  act: (bloc) => bloc.add(MyEvent()),
///  expect: [isA<StateB>()],
/// );
/// ```
@isTest
void blocTest<B extends Bloc<Event, State>, Event, State>(
  String description, {
  @required Future<B> Function() build,
  Future<void> Function(B bloc) act,
  Duration wait,
  int skip = 1,
  Iterable expect,
  Future<void> Function(B bloc) verify,
  Iterable errors,
}) {
  test.test(description, () async {
    final unhandledErrors = <Object>[];
    await runZoned(
      () async {
        final bloc = await build();
        final states = <State>[];
        final subscription = bloc.skip(skip).listen(states.add);
        await act?.call(bloc);
        if (wait != null) await Future.delayed(wait);
        await bloc.close();
        if (expect != null) test.expect(states, expect);
        await subscription.cancel();
        await verify?.call(bloc);
      },
      onError: (error) {
        if (error is BlocUnhandledErrorException) {
          unhandledErrors.add(error.error);
        } else {
          throw error;
        }
      },
    );
    if (errors != null) test.expect(unhandledErrors, errors);
  });
}
