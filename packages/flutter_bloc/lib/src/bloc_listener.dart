import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_web/widgets.dart';

/// Signature for the listener function which takes the [BuildContext] along with the bloc state
/// and is responsible for executing in response to state changes.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// A Flutter [Widget] which takes a [Bloc] and a [BlocWidgetListener]
/// and invokes the listener in response to state changes in the bloc.
/// It should be used for functionality that needs to occur only in response to a state change
/// such as navigation, showing a [SnackBar], showing a [Dialog], etc...
/// The `listener` is guaranteed to only be called once for each state change unlike the
/// `builder` in [BlocBuilder].
class BlocListener<E, S> extends BlocListenerBase<E, S> {
  /// The [Bloc] whose state will be listened to.
  /// Whenever the bloc's state changes, `listener` will be invoked.
  final Bloc<E, S> bloc;

  /// The [BlocWidgetListener] which will be called on every state change (including the `initialState`).
  /// This listener should be used for any code which needs to execute
  /// in response to a state change (`Transition`).
  /// The state will be the `nextState` for the most recent `Transition`.
  final BlocWidgetListener<S> listener;

  /// The [Widget] which will be rendered as a descendant of the [BlocListener].
  final Widget child;

  const BlocListener({
    Key key,
    @required this.bloc,
    @required this.listener,
    this.child,
  })  : assert(bloc != null),
        assert(listener != null),
        super(key: key, bloc: bloc, listener: listener);

  /// Clone the current [BlocListener] with a new child [Widget].
  /// All other values, including [Key], [Bloc] and [BlocWidgetListener] are
  /// preserved.
  BlocListener<E, S> copyWith(Widget child) {
    return BlocListener<E, S>(
      key: key,
      bloc: bloc,
      listener: listener,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => child;
}

/// Base class for widgets that listen to state changes in a specified [Bloc].
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
abstract class BlocListenerBase<E, S> extends StatefulWidget {
  /// The [Bloc] whose state will be listened to.
  /// Whenever the bloc's state changes, `listener` will be invoked.
  final Bloc<E, S> bloc;

  /// The [BlocWidgetListener] which will be called on every state change.
  /// This listener should be used for any code which needs to execute
  /// in response to a state change (`Transition`).
  /// The state will be the `nextState` for the most recent `Transition`.
  final BlocWidgetListener<S> listener;

  const BlocListenerBase({
    Key key,
    @required this.bloc,
    @required this.listener,
  }) : super(key: key);

  State<BlocListenerBase<E, S>> createState() => _BlocListenerBaseState<E, S>();

  /// Returns a [Widget] based on the [BuildContext].
  Widget build(BuildContext context);
}

class _BlocListenerBaseState<E, S> extends State<BlocListenerBase<E, S>> {
  StreamSubscription<S> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc.state != widget.bloc.state) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.bloc.state != null) {
      _subscription = widget.bloc.state.listen((S state) {
        widget.listener.call(context, state);
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
