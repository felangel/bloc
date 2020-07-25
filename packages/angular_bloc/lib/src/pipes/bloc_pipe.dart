import 'dart:async';

import 'package:angular/core.dart'
    show ChangeDetectorRef, OnDestroy, Pipe, PipeTransform;
import 'package:bloc/bloc.dart';

/// {@template bloc_pipe}
/// A `pipe` which helps bind [Bloc] and [Cubit]
/// state changes to the presentation layer.
///
/// [BlocPipe] handles rendering the html element in response to new states.
/// [BlocPipe] is very similar to `AsyncPipe` but has simplified API
/// to reduce the amount of boilerplate code needed.
///
/// See also:
///
/// * [Bloc] for more information about how to make and use blocs.
/// * [Cubit] for more information about how to make and use cubits.
///
/// {@endtemplate}
@Pipe('bloc', pure: false)
class BlocPipe implements OnDestroy, PipeTransform {
  /// {@macro bloc_pipe}
  BlocPipe(this._ref);

  final ChangeDetectorRef _ref;
  Cubit _cubit;
  Object _latestValue;
  StreamSubscription _subscription;

  @override
  void ngOnDestroy() {
    if (_subscription != null) {
      _dispose();
    }
  }

  /// Angular invokes the [transform] method with the value of a binding as the
  /// first argument, and any parameters as the second argument in list form.
  dynamic transform(Cubit cubit) {
    if (_cubit == null) {
      if (cubit != null) {
        _subscribe(cubit);
      }
    } else if (!_maybeStreamIdentical(cubit, _cubit)) {
      _dispose();
      return transform(cubit);
    }
    if (cubit == null) {
      return null;
    }
    return _latestValue ?? cubit.state;
  }

  void _subscribe(Cubit cubit) {
    _cubit = cubit;
    _subscription = cubit.listen(
      (dynamic value) => _updateLatestValue(cubit, value),
      onError: (dynamic e) => throw e,
    );
  }

  void _updateLatestValue(dynamic async, Object value) {
    if (identical(async, _cubit)) {
      _latestValue = value;
      _ref.markForCheck();
    }
  }

  void _dispose() {
    _subscription.cancel();
    _latestValue = null;
    _subscription = null;
    _cubit = null;
  }

  // StreamController.stream getter always returns new Stream instance,
  // operator== check is also needed. See
  // https://github.com/dart-lang/angular2/issues/260
  static bool _maybeStreamIdentical(dynamic a, dynamic b) {
    if (!identical(a, b)) {
      return a is Stream && b is Stream && a == b;
    }
    return true;
  }
}
