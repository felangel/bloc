import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc_provider.dart';
import 'bloc_widget_mixin.dart';

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
///
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
    extends SingleChildStatefulWidget
    with BlocWidgetMixin<C, S>, BlocListenerMixin<C, S> {
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
  @override
  final C cubit;

  /// The [BlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  @override
  final BlocWidgetListener<S> listener;

  /// {@macro bloc_listener_listen_when}
  @override
  final BlocListenerCondition<S> listenWhen;

  @override
  SingleChildState<BlocListenerBase<C, S>> createState() =>
      _BlocListenerBaseState<C, S>();
}

class _BlocListenerBaseState<C extends Cubit<S>, S>
    extends SingleChildState<BlocListenerBase<C, S>>
    with BlocWidgetStateMixin<BlocListenerBase<C, S>, C, S> {
  @override
  Widget buildWithChild(BuildContext context, Widget child) => child;
}

/// The [BlocListenerMixin] define the litener behavior for a [BlocWidgetMixin]
mixin BlocListenerMixin<C extends Cubit<S>, S> on BlocWidgetMixin<C, S> {
  /// The [BlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  BlocWidgetListener<S> get listener;

  /// {@macro bloc_listener_listen_when}
  BlocListenerCondition<S> get listenWhen;

  @override
  void onStateEmitted(
    BuildContext context,
    S previousState,
    S state,
    VoidCallback rebuild,
  ) {
    super.onStateEmitted(context, previousState, state, rebuild);
    if (listenWhen?.call(previousState, state) ?? true) {
      listener?.call(context, state);
    }
  }
}
