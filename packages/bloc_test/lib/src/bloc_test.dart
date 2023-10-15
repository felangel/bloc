import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

/// Defines a step of the saga where an event is added or an action is performed
///
/// [act] is an optional callback which will be invoked with the `bloc` under
/// test and should be used to interact with the `bloc`. In case of adding events to a bloc
/// it's simplier to use [happens], that expect an event. [act] and [happens] are mutually exclusive
/// but both are optional, a [Step] can be used to only check a state.
/// [outputs] is a list of callbacks (bool Function(S value)). For every callback a state
/// is popped out, if the callback result is true the test is passed.
/// [description] A description for the Step, it will output in message, in case of failure
/// [wait] the time to wait prior to check every output
/// [timeOut] the maximum time to wait for states output from the bloc
class Step<B, S> {
  Step(
      {this.act,
      this.happens,
      required this.outputs,
      this.description,
      this.wait = const Duration(milliseconds: 50),
      this.timeOut = const Duration(milliseconds: 150)}) {
    assert(!(happens != null && act != null), "'act' and 'happens' can't be used at the sae time.");
  }
  final dynamic Function(B bloc)? act;
  final Object? happens;
  final List<bool Function(S value)> outputs;
  final String? description;
  final Duration wait;
  final Duration timeOut;
}

/// Creates a new `bloc`-specific test case with the given [description].
/// [blocTest] will handle asserting that the `bloc` emits the [expect]ed
/// states (in order) after [act] is executed.
/// [blocTest] also handles ensuring that no additional states are emitted
/// by closing the `bloc` stream before evaluating the [expect]ation.
///
/// [setUp] is optional and should be used to set up
/// any dependencies prior to initializing the `bloc` under test.
/// [setUp] should be used to set up state necessary for a particular test case.
/// For common set up code, prefer to use `setUp` from `package:test/test.dart`.
///
/// [build] should construct and return the `bloc` under test.
///
/// [seed] is an optional `Function` that returns a state
/// which will be used to seed the `bloc` before [act] is called.
///
/// [act] is an optional callback which will be invoked with the `bloc` under
/// test and should be used to interact with the `bloc`.
///
/// [saga] is an optional parameter that can be used to check if a chain of events matches with desidered state changes
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `bloc` under test such as `debounceTime`.
///
/// [expect] is an optional `Function` that returns a `Matcher` which the `bloc`
/// under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the `bloc` returned by [build].
///
/// [errors] is an optional `Function` that returns a `Matcher` which the `bloc`
/// under test is expected to throw after [act] is executed.
///
/// [tearDown] is optional and can be used to
/// execute any code after the test has run.
/// [tearDown] should be used to clean up after a particular test case.
/// For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.
///
/// [tags] is optional and if it is passed, it declares user-defined tags
/// that are applied to the test. These tags can be used to select or
/// skip the test on the command line, or to do bulk test configuration.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: () => [1],
/// );
/// ```
///
/// [blocTest] can optionally be used with a seeded state.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [10] when seeded with 9',
///   build: () => CounterBloc(),
///   seed: () => 9,
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: () => [10],
/// );
/// ```
///
/// [blocTest] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// [skip] defaults to 0.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [2] when increment is added twice',
///   build: () => CounterBloc(),
///   act: (bloc) {
///     bloc
///       ..add(CounterEvent.increment)
///       ..add(CounterEvent.increment);
///   },
///   skip: 1,
///   expect: () => [2],
/// );
/// ```
///
/// [blocTest] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   wait: const Duration(milliseconds: 300),
///   expect: () => [1],
/// );
/// ```
///
/// [blocTest] can also be used to check if, given a list or event or actions, every step has the desidered output  
/// by optionally providing a `Saga` to [saga].
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when increment is added',
///   build: () => CounterBloc(),
///   saga: [Step(
///           description: 'Initial',
///           outputs: [(state) => state == 0],
///          ),
///         Step(
///           happens: CounterEvent.increment,
///           description: 'Increment ',
///           outputs: [(state) => state == 1],
///         ),
///         Step(
///           act: (bloc) => bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
///           description: 'Double Increment ',
///           outputs: [(state) => state == 2,
///                     (state) => state == 3,],
///           timeOut: Duration(milliseconds: 200),
///         ),],
///   wait: const Duration(milliseconds: 300),
/// );
/// ```
///
/// [blocTest] can also be used to [verify] internal bloc functionality.
///
/// ```dart
/// blocTest(
///   'CounterBloc emits [1] when increment is added',
///   build: () => CounterBloc(),
///   act: (bloc) => bloc.add(CounterEvent.increment),
///   expect: () => [1],
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
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
///  'emits [StateB] when EventB is added',
///  build: () => MyBloc(),
///  act: (bloc) => bloc.add(EventB()),
///  expect: () => [isA<StateB>()],
/// );
/// ```
///
/// If [tags] is passed, it declares user-defined tags that are applied to the
/// test. These tags can be used to select or skip the test on the command line,
/// or to do bulk test configuration. All tags should be declared in the
/// [package configuration file][configuring tags]. The parameter can be an
/// [Iterable] of tag names, or a [String] representing a single tag.
///
/// [configuring tags]: https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md#configuring-tags
@isTest
void blocTest<B extends BlocBase<State>, State>(
  String description, {
  required B Function() build,
  FutureOr<void> Function()? setUp,
  State Function()? seed,
  dynamic Function(B bloc)? act,
  List<Step<B, State>>? saga,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  dynamic Function(B bloc)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
  dynamic tags,
}) {
  test.test(
    description,
    () async {
      await testBloc<B, State>(
        setUp: setUp,
        build: build,
        seed: seed,
        act: act,
        saga: saga,
        wait: wait,
        skip: skip,
        expect: expect,
        verify: verify,
        errors: errors,
        tearDown: tearDown,
      );
    },
    tags: tags,
  );
}

/// Internal [blocTest] runner which is only visible for testing.
/// This should never be used directly -- please use [blocTest] instead.
@visibleForTesting
Future<void> testBloc<B extends BlocBase<State>, State>({
  required B Function() build,
  FutureOr<void> Function()? setUp,
  State Function()? seed,
  dynamic Function(B bloc)? act,
  List<Step<B, State>>? saga,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  dynamic Function(B bloc)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
}) async {
  var shallowEquality = false;
  final unhandledErrors = <Object>[];
  final localBlocObserver =
      // ignore: deprecated_member_use
      BlocOverrides.current?.blocObserver ?? Bloc.observer;
  final testObserver = _TestBlocObserver(
    localBlocObserver,
    unhandledErrors.add,
  );
  Bloc.observer = testObserver;

  try {
    await _runZonedGuarded(() async {
      await setUp?.call();
      final states = <State>[];
      final bloc = build();
      Queue<State>? statesQueue;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (seed != null) bloc.emit(seed());
      final subscription = bloc.stream.skip(skip).listen((s) {
        states.add(s);
        if (statesQueue != null) {
          statesQueue.addLast(s);
        }
      });
      try {
        await act?.call(bloc);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      if (saga != null && saga.isNotEmpty) {
        try {
          statesQueue = Queue<State>();
          await _runSaga(bloc, saga, statesQueue);
        } catch (error) {
          if (errors == null) rethrow;
          unhandledErrors.add(error);
        } finally {
          statesQueue = null;
        }
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      if (expect != null) {
        final dynamic expected = expect();
        shallowEquality = '$states' == '$expected';
        try {
          test.expect(states, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality || expected is! List<State>) rethrow;
          final diff = _diff(expected: expected, actual: states);
          final message = '${e.message}\n$diff';
          // ignore: only_throw_errors
          throw test.TestFailure(message);
        }
      }
      await subscription.cancel();
      await verify?.call(bloc);
      await tearDown?.call();
    });
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      // ignore: only_throw_errors
      throw test.TestFailure(
        '''
${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the blocTest rather than concrete state instances.\n''',
      );
    }
    if (errors == null || !unhandledErrors.contains(error)) {
      rethrow;
    }
  }

  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
Future<void> _runSaga<B, State>(B bloc, List<Step<B, State>> saga, Queue<State> statesQueue,) async {
  for (var step in saga) {
    if (step.happens != null) {
      (bloc as dynamic).add(step.happens);
    }
    if (step.act!=null){
      await step.act?.call(bloc);
    }
    await Future<void>.delayed(Duration.zero);
    // await step.act.call(bloc);
    int i = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    do {
      await Future<void>.delayed(step.wait);
      if (statesQueue.isNotEmpty) {
        var state = statesQueue.removeFirst();
        if (!await step.outputs[i](state)) {
          var message = 'Failed check predicate [$i]';
          if (step.description != null) message = '$message - ${step.description}';
          message = '$message - State: $state';
          throw test.TestFailure(message);
        }
        i++;
      }
    } while (i < step.outputs.length && stopwatch.elapsed < step.timeOut);
    if (i < step.outputs.length) {
      var message = 'Failed checks : received $i states instead of ${step.outputs.length}';
      if (step.description != null) message = '$message - ${step.description}';
    }
  }
}

Future<void> _runZonedGuarded(Future<void> Function() body) {
  final completer = Completer<void>();
  runZonedGuarded(() async {
    await body();
    if (!completer.isCompleted) completer.complete();
  }, (error, stackTrace) {
    if (!completer.isCompleted) completer.completeError(error, stackTrace);
  });
  return completer.future;
}

class _TestBlocObserver extends BlocObserver {
  const _TestBlocObserver(this._localObserver, this._onError);

  final BlocObserver _localObserver;
  final void Function(Object error) _onError;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _localObserver.onError(bloc, error, stackTrace);
    _onError(error);
    super.onError(bloc, error, stackTrace);
  }
}

String _diff({required dynamic expected, required dynamic actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());
  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln()
    ..writeln(differences.toPrettyString())
    ..writeln()
    ..writeln('${"=" * 4} end diff ${"=" * 36}');
  return buffer.toString();
}

extension on List<Diff> {
  String toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
          break;
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
          break;
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
          break;
      }
    }
    return buffer.toString();
  }
}
