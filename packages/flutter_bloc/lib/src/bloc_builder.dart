import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';

/// A function that will be run which takes the [BuildContext] and state
/// and is responsible for returning a [Widget] which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// A Flutter widget which requires a [Bloc] and a [BlocWidgetBuilder] `builder` function.
/// [BlocBuilder] handles building the widget in response to new states.
/// BlocBuilder analogous to [StreamBuilder] but has simplified API
/// to reduce the amount of boilerplate code needed
/// as well as bloc-specific performance improvements.
class BlocBuilder<E, S> extends BlocBuilderBase<E, S> {
  final Bloc<E, S> bloc;
  final BlocWidgetBuilder<S> builder;

  const BlocBuilder({Key key, @required this.bloc, @required this.builder})
      : assert(bloc != null),
        assert(builder != null),
        super(key: key, bloc: bloc);

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// Base class for widgets that build themselves based on interaction with
/// a specified [Bloc].
///
/// A [BlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
abstract class BlocBuilderBase<E, S> extends StatefulWidget {
  const BlocBuilderBase({Key key, this.bloc}) : super(key: key);

  /// The [Bloc] that the [BlocBuilderBase] will interact with.
  final Bloc<E, S> bloc;

  /// Returns a [Widget] based on the [BuildContext] and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<E, S>> createState() => _BlocBuilderBaseState<E, S>();
}

class _BlocBuilderBaseState<E, S> extends State<BlocBuilderBase<E, S>> {
  StreamSubscription<S> _subscription;
  S _state;

  @override
  void initState() {
    super.initState();
    _state = widget.bloc.currentState;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc.state != widget.bloc.state) {
      if (_subscription != null) {
        _unsubscribe();
        _state = widget.bloc.currentState;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.bloc.state != null) {
      _subscription = widget.bloc.state.skip(1).listen((S state) {
        setState(() {
          _state = state;
        });
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
