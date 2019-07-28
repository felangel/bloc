import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for the builder function which takes the [BuildContext] and state
/// and is responsible for returning a [Widget] which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the condition function which takes the previous state and the current state
/// and is responsible for returning a `bool` which determines whether or not to rebuild
/// [BlocBuilder] with the current state.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

class BlocBuilder<B extends Bloc<dynamic, S>, S> extends BlocBuilderBase<B, S> {
  /// The `builder` function which will be invoked on each widget build.
  /// The `builder` takes the [BuildContext] and current bloc state and
  /// must return a [Widget].
  /// This is analogous to the `builder` function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// [BlocBuilder] handles building a widget in response to new states.
  /// [BlocBuilder] is analogous to [StreamBuilder] but has simplified API
  /// to reduce the amount of boilerplate code needed as well as bloc-specific performance improvements.

  /// Please refer to [BlocListener] if you want to "do" anything in response to state changes such as
  /// navigation, showing a dialog, etc...
  ///
  /// If the bloc parameter is omitted, [BlocBuilder] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   builder: (context, state) {
  ///   // return widget here based on BlocA's state
  ///   }
  /// )
  /// ```
  ///
  /// Only specify the bloc if you wish to provide a bloc that is otherwise
  /// not accessible via [BlocProvider] and the current [BuildContext].
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   bloc: blocA,
  ///   builder: (context, state) {
  ///   // return widget here based on BlocA's state
  ///   }
  /// )
  /// ```
  ///
  /// An optional `condition` can be implemented for more granular control
  /// over how often [BlocBuilder] rebuilds.
  /// The `condition` function will be invoked on each bloc state change.
  /// The `condition` takes the previous state and current state and must return a `bool`
  /// which determines whether or not the `builder` function will be invoked.
  /// The previous state will be initialized to `currentState` when the [BlocBuilder] is initialized.
  /// `condition` is optional and if it isn't implemented, it will default to return `true`.
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   condition: (previousState, currentState) {
  ///     // return true/false to determine whether or not
  ///     // to rebuild the widget with currentState
  ///   },
  ///   builder: (context, state) {
  ///     // return widget here based on BlocA's state
  ///   }
  ///)
  /// ```
  const BlocBuilder({
    Key key,
    @required this.builder,
    B bloc,
    BlocBuilderCondition<S> condition,
  })  : assert(builder != null),
        super(key: key, bloc: bloc, condition: condition);

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

abstract class BlocBuilderBase<B extends Bloc<dynamic, S>, S>
    extends StatefulWidget {
  /// Base class for widgets that build themselves based on interaction with
  /// a specified [Bloc].
  ///
  /// A [BlocBuilderBase] is stateful and maintains the state of the interaction
  /// so far. The type of the state and how it is updated with each interaction
  /// is defined by sub-classes.
  const BlocBuilderBase({Key key, this.bloc, this.condition}) : super(key: key);

  /// The [Bloc] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  final B bloc;

  /// The [BlocBuilderCondition] that the [BlocBuilderBase] will invoke.
  /// The `condition` function will be invoked on each bloc state change.
  /// The `condition` takes the previous state and current state and must return a `bool`
  /// which determines whether or not the `builder` function will be invoked.
  /// The previous state will be initialized to `currentState` when the [BlocBuilderBase] is initialized.
  /// `condition` is optional and if it isn't implemented, it will default to return `true`.
  final BlocBuilderCondition<S> condition;

  /// Returns a [Widget] based on the [BuildContext] and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<B, S>> createState() => _BlocBuilderBaseState<B, S>();
}

class _BlocBuilderBaseState<B extends Bloc<dynamic, S>, S>
    extends State<BlocBuilderBase<B, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;
  B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? BlocProvider.of<B>(context);
    _previousState = _bloc?.currentState;
    _state = _bloc?.currentState;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Stream<S> oldState =
        oldWidget.bloc?.state ?? BlocProvider.of<B>(context).state;
    final Stream<S> currentState = widget.bloc?.state ?? oldState;
    if (oldState != currentState) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = widget.bloc ?? BlocProvider.of<B>(context);
        _previousState = _bloc?.currentState;
        _state = _bloc?.currentState;
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
    if (_bloc?.state != null) {
      _subscription = _bloc.state.skip(1).listen((S state) {
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
