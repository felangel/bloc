import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'bloc_provider.dart';

/// {@template bloc_wigdet_mixin}
/// Base class for widgets that build themselves based on interaction with
/// a specified [cubit].
///
/// A [BlocWidgetMixin] extends a stateful and maintains the state of the
/// interaction so far. The type of the state and how it is updated with each
/// interaction is defined by sub-classes.
/// {@endtemplate}
mixin BlocWidgetMixin<C extends Cubit<S>, S> on StatefulWidget {
  /// The [cubit] that the [BlocWidgetMixin] will interact with.
  /// If omitted, [BlocWidgetMixin] will automatically perform a lookup using
  /// [BlocProvider] and the current `BuildContext`.
  C get cubit;

  /// The [onStateEmitted] is invoked when the `state` of [cubit] is emitted.
  /// if returns `true`, the widget will rebuild.
  @protected
  @mustCallSuper
  bool onStateEmitted(BuildContext context, S previousState, S state) => true;
}

/// The [BlocWidgetStateMixin] handles the subscription to the optional
/// [BlocWidgetMixin.cubit]. When a new `state` is emitted,
/// [BlocWidgetMixin/onStateChanged] will be invoked.
mixin BlocWidgetStateMixin<W extends BlocWidgetMixin<C, S>, C extends Cubit<S>,
    S> on State<W> {
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  /// Current `state` from `cubit`
  S get state => _cubit?.state;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.bloc<C>();
    _previousState = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.bloc<C>();
    final currentBloc = widget.cubit ?? oldCubit;
    if (oldCubit != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.bloc<C>();
        _previousState = _cubit?.state;
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (widget.onStateEmitted(context, _previousState, state) ?? true) {
          setState(() {});
        }
        _previousState = state;
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
