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

  @protected
  List<VoidCallback> filterReactions(
    BlocWidgetStateMixin<BlocWidgetMixin<C, S>, C, S> widgetState,
  );
}

mixin BlocWidgetStateMixin<W extends BlocWidgetMixin<C, S>, C extends Cubit<S>,
    S> on State<W> {
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  /// Previous state from cubit
  S get previous => _previousState;

  /// Current state from cubit
  S get current => _cubit?.state;

  /// Current cubit
  C get cubit => _cubit;

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
        final actions = widget.filterReactions(this);
        assert(actions != null);
        for (final action in actions) {
          action?.call();
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
