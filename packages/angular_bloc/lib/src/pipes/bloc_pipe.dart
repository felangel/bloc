import 'dart:async';

import 'package:angular/core.dart'
    show ChangeDetectorRef, OnDestroy, Pipe, PipeTransform;

import 'package:bloc/bloc.dart';

@Pipe('bloc', pure: false)
class BlocPipe implements OnDestroy, PipeTransform {
  Bloc _bloc;
  Object _latestValue;
  StreamSubscription _subscription;
  ChangeDetectorRef _ref;

  BlocPipe(this._ref);

  @override
  void ngOnDestroy() {
    if (_subscription != null) {
      _dispose();
    }
  }

  dynamic transform(Bloc bloc) {
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
    return _latestValue ?? bloc.initialState;
  }

  void _subscribe(Bloc bloc) {
    _bloc = bloc;
    _subscription = bloc.state.listen(
        (Object value) => _updateLatestValue(bloc, value),
        onError: (dynamic e) => throw e);
  }

  void _updateLatestValue(dynamic async, Object value) {
    if (identical(async, _bloc)) {
      _latestValue = value;
      _ref.markForCheck();
    }
  }

  void _dispose() {
    _subscription.cancel();
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
