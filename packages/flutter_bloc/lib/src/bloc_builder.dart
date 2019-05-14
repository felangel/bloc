import 'dart:async';

import 'package:flutter_web/widgets.dart';

import 'package:bloc/bloc.dart';

/// Signature for the builder function which takes the [BuildContext] and state
/// and is responsible for returning a [Widget] which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the condition function which takes the previous state and the current state
/// and is responsible for returning a `bool` which determines whether or not to rebuild
/// [BlocBuilder] with the current state.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

class BlocBuilder<E, S> extends BlocBuilderBase<E, S> {
  /// The [Bloc] that the [BlocBuilder] will interact with.
  final Bloc<E, S> bloc;

  /// The `builder` function which will be invoked on each widget build.
  /// The `builder` takes the [BuildContext] and current bloc state and
  /// must return a [Widget].
  /// This is analogous to the `builder` function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// The `condition` function will be invoked on each bloc state change.
  /// The `condition` takes the previous state and current state and must return a `bool`
  /// which determines whether or not the `builder` function will be invoked.
  /// The previous state will be initialized to `currentState` when the [BlocBuilder] is initialized.
  /// `condition` is optional and if it isn't implemented, it will default to return `true`.
  ///
  /// ```dart
  /// BlocBuilder(
  ///   bloc: BlocProvider.of<BlocA>(context),
  ///   condition: (previousState, currentState) {
  ///     // return true/false to determine whether or not
  ///     // to rebuild the widget with currentState
  ///   },
  ///   builder: (context, state) {
  ///     // return widget here based on BlocA's state
  ///   }
  ///)
  /// ```
  final BlocBuilderCondition<S> condition;

  /// [BlocBuilder] handles building a widget in response to new states.
  /// [BlocBuilder] is analogous to [StreamBuilder] but has simplified API
  /// to reduce the amount of boilerplate code needed as well as bloc-specific performance improvements.
  ///
  /// ```dart
  /// BlocBuilder(
  ///   bloc: BlocProvider.of<BlocA>(context),
  ///   builder: (BuildContext context, BlocAState state) {
  ///   // return widget here based on BlocA's state
  ///   }
  /// )
  /// ```
  const BlocBuilder({
    Key key,
    @required this.bloc,
    @required this.builder,
    this.condition,
  })  : assert(bloc != null),
        assert(builder != null),
        super(key: key, bloc: bloc);

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

abstract class BlocBuilderBase<E, S> extends StatefulWidget {
  /// Base class for widgets that build themselves based on interaction with
  /// a specified [Bloc].
  ///
  /// A [BlocBuilderBase] is stateful and maintains the state of the interaction
  /// so far. The type of the state and how it is updated with each interaction
  /// is defined by sub-classes.
  const BlocBuilderBase({Key key, this.bloc, this.condition}) : super(key: key);

  /// The [Bloc] that the [BlocBuilderBase] will interact with.
  final Bloc<E, S> bloc;

  /// The [BlocBuilderCondition] that the [BlocBuilderBase] will invoke.
  final BlocBuilderCondition<S> condition;

  /// Returns a [Widget] based on the [BuildContext] and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<E, S>> createState() => _BlocBuilderBaseState<E, S>();
}

class _BlocBuilderBaseState<E, S> extends State<BlocBuilderBase<E, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;

  @override
  void initState() {
    super.initState();
    _previousState = widget.bloc.currentState;
    _state = widget.bloc.currentState;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc.state != widget.bloc.state) {
      if (_subscription != null) {
        _unsubscribe();
        _previousState = widget.bloc.currentState;
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
        if (widget.condition?.call(_previousState, state) ?? true) {
          setState(() {
            _state = state;
          });
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
