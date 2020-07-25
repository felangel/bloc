import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc_provider.dart';

/// Mixin which allows `MultiBlocListener` to infer the types
/// of multiple [BlocListener]s.
mixin BlocListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [BlocWidgetListener] of [BlocListener]
/// with the current `state`.
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloc_listener}
/// Takes a [BlocWidgetListener] and an optional [cubit] and invokes
/// the [listener] in response to `state` changes in the [cubit].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///
/// If the [cubit] parameter is omitted, [BlocListener] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [cubit] if you wish to provide a [cubit] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   bloc: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [cubit] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit]
/// when the [BlocListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   }
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    with BlocListenerSingleChildWidget {
  /// {@macro bloc_listener}
  const BlocListener({
    Key key,
    @required BlocWidgetListener<S> listener,
    C cubit,
    BlocListenerCondition<S> listenWhen,
    this.child,
  })  : assert(listener != null),
        super(
          key: key,
          child: child,
          listener: listener,
          cubit: cubit,
          listenWhen: listenWhen,
        );

  /// The widget which will be rendered as a descendant of the [BlocListener].
  @override
  // ignore: overridden_fields
  final Widget child;
}

/// {@template bloc_listener_base}
/// Base class for widgets that listen to state changes in a specified [cubit].
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocListenerBase<C extends Cubit<S>, S>
    extends SingleChildStatefulWidget {
  /// {@macro bloc_listener_base}
  const BlocListenerBase({
    Key key,
    this.listener,
    this.cubit,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// The widget which will be rendered as a descendant of the
  /// [BlocListenerBase].
  final Widget child;

  /// The [cubit] whose `state` will be listened to.
  /// Whenever the [cubit]'s `state` changes, [listener] will be invoked.
  final C cubit;

  /// The [BlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final BlocWidgetListener<S> listener;

  /// {@macro bloc_listener_listen_when}
  final BlocListenerCondition<S> listenWhen;

  @override
  SingleChildState<BlocListenerBase<C, S>> createState() =>
      _BlocListenerBaseState<C, S>();
}

class _BlocListenerBaseState<C extends Cubit<S>, S>
    extends SingleChildState<BlocListenerBase<C, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.bloc<C>();
    _previousState = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.bloc<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.bloc<C>();
        _previousState = _cubit?.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) => child;

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (widget.listenWhen?.call(_previousState, state) ?? true) {
          widget.listener(context, state);
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
