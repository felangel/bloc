import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import '../flutter_bloc.dart';

/// Mixin which allows `MultiBlocListener` to infer the types
/// of multiple [BlocListener]s.
mixin BlocListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the [listener] function which takes the `BuildContext` along
/// with the [bloc] [state] and is responsible for executing in response to
/// [state] changes.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// Signature for the [condition] function which takes the previous [state]
/// and the current [state] and is responsible for returning a [bool] which
/// determines whether or not to call [BlocWidgetListener] of [BlocListener]
/// with the current [state].
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloclistener}
/// Takes a [BlocWidgetListener] and an optional [bloc] and invokes
/// the [listener] in response to [state] changes in the [bloc].
/// It should be used for functionality that needs to occur only in response to
/// a [state] change such as navigation, showing a [SnackBar], showing
/// a [Dialog], etc...
/// The [listener] is guaranteed to only be called once for each [state] change
/// unlike the [builder] in [BlocBuilder].
///
/// If the [bloc] parameter is omitted, [BlocListener] will automatically
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
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
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
///
/// An optional [condition] can be implemented for more granular control
/// over when [listener] is called.
/// The [condition] function will be invoked on each [bloc] [state] change.
/// The [condition] takes the previous [state] and current [state] and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous [state] will be initialized to the [state] of the [bloc]
/// when the [BlocListener] is initialized.
/// [condition] is optional and if it isn't implemented, it will default to
/// `true`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   condition: (previous, current) {
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
class BlocListener<B extends Bloc<dynamic, S>, S> extends BlocListenerBase<B, S>
    with BlocListenerSingleChildWidget {
  /// The widget which will be rendered as a descendant of the [BlocListener].
  final Widget child;

  /// {@macro bloclistener}
  const BlocListener({
    Key key,
    @required BlocWidgetListener<S> listener,
    B bloc,
    BlocListenerCondition<S> condition,
    this.child,
  })  : assert(listener != null),
        super(
          key: key,
          child: child,
          listener: listener,
          bloc: bloc,
          condition: condition,
        );
}

/// {@template bloclistenerbase}
/// Base class for widgets that listen to state changes in a specified [bloc].
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocListenerBase<B extends Bloc<dynamic, S>, S>
    extends SingleChildStatefulWidget {
  /// The widget which will be rendered as a descendant of the
  /// [BlocListenerBase].
  final Widget child;

  /// The [bloc] whose [state] will be listened to.
  /// Whenever the [bloc]'s [state] changes, [listener] will be invoked.
  final B bloc;

  /// The [BlocWidgetListener] which will be called on every [state] change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a [state] change ([Transition]).
  /// The [state] will be the [nextState] for the most recent [Transition].
  final BlocWidgetListener<S> listener;

  /// The [BlocListenerCondition] that the [BlocListenerBase] will invoke.
  /// The [condition] function will be invoked on each [bloc] [state] change.
  /// The [condition] takes the previous [state] and current [state] and must
  /// return a [bool] which determines whether or not the [listener] function
  /// will be invoked.
  /// The previous [state] will be initialized to [state] when
  /// the [BlocListenerBase] is initialized.
  /// [condition] is optional and if it isn't implemented, it will default to
  /// `true`.
  final BlocListenerCondition<S> condition;

  /// {@macro bloclistenerbase}
  const BlocListenerBase({
    Key key,
    this.listener,
    this.bloc,
    this.child,
    this.condition,
  }) : super(key: key, child: child);

  @override
  SingleChildState<BlocListenerBase<B, S>> createState() =>
      _BlocListenerBaseState<B, S>();
}

class _BlocListenerBaseState<B extends Bloc<dynamic, S>, S>
    extends SingleChildState<BlocListenerBase<B, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? BlocProvider.of<B>(context);
    _previousState = _bloc?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldState = oldWidget.bloc ?? BlocProvider.of<B>(context);
    final currentState = widget.bloc ?? oldState;
    if (oldState != currentState) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = widget.bloc ?? BlocProvider.of<B>(context);
        _previousState = _bloc?.state;
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
    if (_bloc != null) {
      _subscription = _bloc.skip(1).listen((state) {
        if (widget.condition?.call(_previousState, state) ?? true) {
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
