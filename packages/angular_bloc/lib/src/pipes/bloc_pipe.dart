import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ngdart/angular.dart' show ChangeDetectorRef, OnDestroy, Pipe;

/// {@template bloc_pipe}
/// A `pipe` which helps bind [BlocBase] ([Bloc] and [Cubit])
/// state changes to the presentation layer.
///
/// [BlocPipe] handles rendering the html element in response to new states.
/// [BlocPipe] is very similar to `AsyncPipe` but is designed
/// specifically for blocs.
///
/// ```html
/// <p>Current Count: {{ $pipe.bloc(counterBloc) }}</p>
/// ```
///
/// See also:
///
/// * [Bloc] for more information about how to make and use blocs.
/// * [Cubit] for more information about how to make and use cubits.
///
/// {@endtemplate}
@Pipe('bloc', pure: false)
class BlocPipe implements OnDestroy {
  /// {@macro bloc_pipe}
  BlocPipe(this._ref);

  final ChangeDetectorRef _ref;
  BlocBase? _bloc;
  Object? _latestValue;
  StreamSubscription? _subscription;

  @override
  void ngOnDestroy() {
    if (_subscription != null) {
      _dispose();
    }
  }

  /// Angular invokes the [transform] method with the value of a binding as the
  /// first argument, and any parameters as the second argument in list form.
  dynamic transform(BlocBase? bloc) {
    if (_bloc == null) {
      if (bloc != null) {
        _subscribe(bloc);
      }
    } else if (!_maybeStreamIdentical(bloc, _bloc)) {
      _dispose();
      return transform(bloc);
    }
    if (bloc == null) {
      return null;
    }
    return _latestValue ?? bloc.state;
  }

  void _subscribe(BlocBase bloc) {
    _bloc = bloc;
    _subscription = bloc.stream.listen(
      (dynamic value) => _updateLatestValue(bloc, value),
    );
  }

  void _updateLatestValue(dynamic async, Object? value) {
    if (identical(async, _bloc)) {
      _latestValue = value;
      _ref.markForCheck();
    }
  }

  void _dispose() {
    _subscription?.cancel();
    _latestValue = null;
    _subscription = null;
    _bloc = null;
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
