import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'bloc_provider.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [BlocBuilder] with the current `state`.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

/// {@template bloc_builder}
/// [BlocBuilder] handles building a widget in response to new `states`.
/// [BlocBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [cubit]-specific
/// performance improvements.

/// Please refer to `BlocListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [cubit] parameter is omitted, [BlocBuilder] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [cubit] if you wish to provide a [cubit] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   cubit: blocA,
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
/// {@template bloc_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [BlocBuilder] rebuilds.
/// [buildWhen] will be invoked on each [cubit] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit] when
/// the [BlocBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
///)
/// ```
/// {@endtemplate}
class BlocBuilder<C extends Cubit<S>, S> extends BlocBuilderBase<C, S> {
  /// {@macro bloc_builder}
  const BlocBuilder({
    Key key,
    @required this.builder,
    C cubit,
    BlocBuilderCondition<S> buildWhen,
  })  : assert(builder != null),
        super(key: key, cubit: cubit, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// {@template bloc_builder_base}
/// Base class for widgets that build themselves based on interaction with
/// a specified [cubit].
///
/// A [BlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocBuilderBase<C extends Cubit<S>, S> extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const BlocBuilderBase({Key key, this.cubit, this.buildWhen})
      : super(key: key);

  /// The [cubit] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current `BuildContext`.
  final C cubit;

  /// {@macro bloc_builder_build_when}
  final BlocBuilderCondition<S> buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<C, S>> createState() => _BlocBuilderBaseState<C, S>();
}

class _BlocBuilderBaseState<C extends Cubit<S>, S>
    extends State<BlocBuilderBase<C, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.bloc<C>();
    _previousState = _cubit?.state;
    _state = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.bloc<C>();
    final currentBloc = widget.cubit ?? oldCubit;
    if (oldCubit != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.bloc<C>();
        _previousState = _cubit?.state;
        _state = _cubit?.state;
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
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (widget.buildWhen?.call(_previousState, state) ?? true) {
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
