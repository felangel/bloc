// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';

import 'package:mockito/mockito.dart';

/// Extend or mixin this class to mark the implementation as a [MockBloc].
///
/// A mocked bloc implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when] and [whenListen].
///
/// _**Note**: it is critical to explicitly provide the bloc event and state
/// types when extending [MockBloc]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterBloc extends MockBloc<CounterEvent, int>
///   implements CounterBloc {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterBloc extends MockBloc implements CounterBloc {}
/// ```
class MockBloc<E, S> extends Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString().split('"')[1];
    final result = super.noSuchMethod(invocation);
    return (memberName == 'skip' && result == null)
        ? Stream<S>.empty()
        : result;
  }
}
