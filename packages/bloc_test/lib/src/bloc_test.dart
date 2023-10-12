import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

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
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (seed != null) bloc.emit(seed());
      final subscription = bloc.stream.skip(skip).listen(states.add);
      try {
        await act?.call(bloc);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      if (expect != null) {
        final dynamic expected = await expect();
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
