// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';

import 'package:mockito/mockito.dart';

/// Extend or mixin this class to mark the implementation as a [MockCubit].
///
/// A mocked cubit implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when] and `whenListen`.
///
/// _**Note**: it is critical to explicitly provide the cubit event and state
/// types when extending [MockCubit]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterCubit extends MockCubit<CounterEvent, int>
///   implements CounterCubit {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterCubit extends MockCubit implements CounterCubit {}
/// ```
class MockCubit<S> extends Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString().split('"')[1];
    final dynamic result = super.noSuchMethod(invocation);
    return (memberName == 'skip' && result == null)
        ? Stream<S>.empty()
        : result;
  }
}
