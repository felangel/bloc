import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:flutter/widgets.dart';

import 'cubit_provider.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef CubitWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [CubitBuilder] with the current `state`.
typedef CubitBuilderCondition<S> = bool Function(S previous, S current);

/// {@template cubit_builder}
/// [CubitBuilder] handles building a widget in response to new `states`.
/// [CubitBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [cubit]-specific
/// performance improvements.

/// Please refer to `CubitListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [cubit] parameter is omitted, [CubitBuilder] will automatically
/// perform a lookup using [CubitProvider] and the current `BuildContext`.
///
/// ```dart
/// CubitBuilder<CubitA, CubitAState>(
///   builder: (context, state) {
///   // return widget here based on CubitA's state
///   }
/// )
/// ```
///
/// Only specify the [cubit] if you wish to provide a [cubit] that is otherwise
/// not accessible via [CubitProvider] and the current `BuildContext`.
///
/// ```dart
/// CubitBuilder<CubitA, CubitAState>(
///   cubit: cubitA,
///   builder: (context, state) {
///   // return widget here based on CubitA's state
///   }
/// )
/// ```
/// {@endtemplate}
/// {@template cubit_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [CubitBuilder] rebuilds.
/// [buildWhen] will be invoked on each [cubit] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit] when
/// the [CubitBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// CubitBuilder<CubitA, CubitAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on CubitA's state
///   }
///)
/// ```
/// {@endtemplate}
class CubitBuilder<C extends CubitStream<S>, S> extends CubitBuilderBase<C, S> {
  /// {@macro cubit_builder}
  const CubitBuilder({
    Key key,
    @required this.builder,
    C cubit,
    CubitBuilderCondition<S> buildWhen,
  })  : assert(builder != null),
        super(key: key, cubit: cubit, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final CubitWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// {@template cubit_builder_base}
/// Base class for widgets that build themselves based on interaction with
/// a specified [cubit].
///
/// A [CubitBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
/// {@endtemplate}
abstract class CubitBuilderBase<C extends CubitStream<S>, S>
    extends StatefulWidget {
  /// {@macro cubit_builder_base}
  const CubitBuilderBase({Key key, this.cubit, this.buildWhen})
      : super(key: key);

  /// The [cubit] that the [CubitBuilderBase] will interact with.
  /// If omitted, [CubitBuilderBase] will automatically perform a lookup using
  /// [CubitProvider] and the current `BuildContext`.
  final C cubit;

  /// {@macro cubit_builder_build_when}
  final CubitBuilderCondition<S> buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<CubitBuilderBase<C, S>> createState() => _CubitBuilderBaseState<C, S>();
}

class _CubitBuilderBaseState<C extends CubitStream<S>, S>
    extends State<CubitBuilderBase<C, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.cubit<C>();
    _previousState = _cubit?.state;
    _state = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(CubitBuilderBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.cubit<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.cubit<C>();
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
      _subscription = _cubit.skip(1).listen((state) {
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
