import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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
/// Takes a [BlocWidgetListener] and an optional [value] and invokes
/// the [listener] in response to `state` changes in the [value].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///
/// If the [value] parameter is omitted, [BlocListener] will automatically
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
/// Only specify the [value] if you wish to provide a bloc/cubit that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   value: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
///
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the bloc/cubit
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
class BlocListener<T extends Cubit<S>, S> extends BlocListenerBase<T, S>
    with BlocListenerSingleChildWidget {
  /// {@macro bloc_listener}
  const BlocListener({
    Key? key,
    required BlocWidgetListener<S> listener,
    T? value,
    BlocListenerCondition<S>? listenWhen,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          value: value,
          listenWhen: listenWhen,
        );
}

/// {@template bloc_listener_base}
/// Base class for widgets that listen to state changes in a specified bloc/cubit.
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocListenerBase<T extends Cubit<S>, S>
    extends SingleChildStatefulWidget {
  /// {@macro bloc_listener_base}
  const BlocListenerBase({
    Key? key,
    required this.listener,
    this.value,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// The widget which will be rendered as a descendant of the
  /// [BlocListenerBase].
  final Widget? child;

  /// The bloc/cubit which will be listened to.
  /// Whenever the `state` changes, [listener] will be invoked.
  final T? value;

  /// The [BlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final BlocWidgetListener<S> listener;

  /// {@macro bloc_listener_listen_when}
  final BlocListenerCondition<S>? listenWhen;

  @override
  SingleChildState<BlocListenerBase<T, S>> createState() =>
      _BlocListenerBaseState<T, S>();
}

class _BlocListenerBaseState<T extends Cubit<S>, S>
    extends SingleChildState<BlocListenerBase<T, S>> {
  StreamSubscription<S>? _subscription;
  late S _previousState;
  late T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.value ?? context.read<T>();
    _previousState = _bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.value ?? context.read<T>();
    final currentBloc = widget.value ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => child!;

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.listen((state) {
      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
