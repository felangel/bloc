import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
/// reduce the amount of boilerplate code needed as well as [bloc]-specific
/// performance improvements.

/// Please refer to [BlocListener] if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [bloc] parameter is omitted, [BlocBuilder] will automatically
/// perform a lookup using [BlocProvider] and the current [BuildContext].
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
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
/// {@endtemplate}
///
/// {@template bloc_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [BlocBuilder] rebuilds.
/// [buildWhen] should only be used for performance optimizations as it
/// provides no security about the state passed to the [builder] function.
/// [buildWhen] will be invoked on each [bloc] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
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
/// )
/// ```
/// {@endtemplate}
class BlocBuilder<B extends StateStreamable<S>, S>
    extends BlocBuilderBase<B, S> {
  /// {@macro bloc_builder}
  /// {@macro bloc_builder_build_when}
  const BlocBuilder({
    required this.builder,
    Key? key,
    B? bloc,
    BlocBuilderCondition<S>? buildWhen,
  }) : super(key: key, bloc: bloc, buildWhen: buildWhen);

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
/// a specified [bloc].
///
/// A [BlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocBuilderBase<B extends StateStreamable<S>, S>
    extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const BlocBuilderBase({Key? key, this.bloc, this.buildWhen})
      : super(key: key);

  /// The [bloc] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current `BuildContext`.
  final B? bloc;

  /// {@macro bloc_builder_build_when}
  final BlocBuilderCondition<S>? buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<B, S>> createState() => _BlocBuilderBaseState<B, S>();
}

class _BlocBuilderBaseState<B extends StateStreamable<S>, S>
    extends State<BlocBuilderBase<B, S>> {
  late B _bloc;
  late S _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = _bloc.state;
  }

  @override
  void didUpdateWidget(BlocBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }
}
