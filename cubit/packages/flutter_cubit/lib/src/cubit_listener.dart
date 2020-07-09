import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'cubit_provider.dart';

/// Mixin which allows `MultiCubitListener` to infer the types
/// of multiple [CubitListener]s.
mixin CubitListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `cubit` `state` and is responsible for executing in response to
/// `state` changes.
typedef CubitWidgetListener<S> = void Function(BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [CubitWidgetListener] of [CubitListener]
/// with the current `state`.
typedef CubitListenerCondition<S> = bool Function(S previous, S current);

/// {@template cubit_listener}
/// Takes a [CubitWidgetListener] and an optional [cubit] and invokes
/// the [listener] in response to `state` changes in the [cubit].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `CubitBuilder`.
///
/// If the [cubit] parameter is omitted, [CubitListener] will automatically
/// perform a lookup using [CubitProvider] and the current `BuildContext`.
///
/// ```dart
/// CubitListener<CubitA, CubitAState>(
///   listener: (context, state) {
///     // do stuff here based on CubitA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [cubit] if you wish to provide a [cubit] that is otherwise
/// not accessible via [CubitProvider] and the current `BuildContext`.
///
/// ```dart
/// CubitListener<CubitA, CubitAState>(
///   cubit: cubitA,
///   listener: (context, state) {
///     // do stuff here based on CubitA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
/// {@template cubit_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [cubit] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit]
/// when the [CubitListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// CubitListener<CubitA, CubitAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on CubitA's state
///   }
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class CubitListener<C extends CubitStream<S>, S> extends CubitListenerBase<C, S>
    with CubitListenerSingleChildWidget {
  /// {@macro cubit_listener}
  const CubitListener({
    Key key,
    @required CubitWidgetListener<S> listener,
    C cubit,
    CubitListenerCondition<S> listenWhen,
    this.child,
  })  : assert(listener != null),
        super(
          key: key,
          child: child,
          listener: listener,
          cubit: cubit,
          listenWhen: listenWhen,
        );

  /// The widget which will be rendered as a descendant of the [CubitListener].
  @override
  // ignore: overridden_fields
  final Widget child;
}

/// {@template cubit_listener_base}
/// Base class for widgets that listen to state changes in a specified [cubit].
///
/// A [CubitListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class CubitListenerBase<C extends CubitStream<S>, S>
    extends SingleChildStatefulWidget {
  /// {@macro cubit_listener_base}
  const CubitListenerBase({
    Key key,
    this.listener,
    this.cubit,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// The widget which will be rendered as a descendant of the
  /// [CubitListenerBase].
  final Widget child;

  /// The [cubit] whose `state` will be listened to.
  /// Whenever the [cubit]'s `state` changes, [listener] will be invoked.
  final C cubit;

  /// The [CubitWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final CubitWidgetListener<S> listener;

  /// {@macro cubit_listener_listen_when}
  final CubitListenerCondition<S> listenWhen;

  @override
  SingleChildState<CubitListenerBase<C, S>> createState() =>
      _CubitListenerBaseState<C, S>();
}

class _CubitListenerBaseState<C extends CubitStream<S>, S>
    extends SingleChildState<CubitListenerBase<C, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.cubit<C>();
    _previousState = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(CubitListenerBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.cubit<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.cubit<C>();
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
      _subscription = _cubit.skip(1).listen((state) {
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
