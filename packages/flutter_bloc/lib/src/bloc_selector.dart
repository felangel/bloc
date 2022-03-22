import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [state].
typedef BlocWidgetSelector<S, T> = T Function(S state);

/// {@template bloc_selector}
/// [BlocSelector] is analogous to [BlocBuilder] but allows developers to
/// filter updates by selecting a new value based on the bloc state.
/// Unnecessary builds are prevented if the selected value does not change.
///
/// **Note**: the selected value must be immutable in order for [BlocSelector]
/// to accurately determine whether [builder] should be called again.
///
/// ```dart
/// BlocSelector<BlocA, BlocAState, SelectedState>(
///   selector: (state) {
///     // return selected state based on the provided state.
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class BlocSelector<B extends StateStreamable<S>, S, T> extends StatefulWidget {
  /// {@macro bloc_selector}
  const BlocSelector({
    Key? key,
    required this.selector,
    required BlocWidgetBuilder<T> builder,
    this.bloc,
  })  : child = null,
        builder = builder,
        builderChild = null,
        super(key: key);

  /// Similar to [BlocSelector] but gives a [child] parameter
  /// as a pre-built subtree and pass it back to the `builderChild` function.
  /// The [child] is built only the first time. This is good for whene
  /// a part of your widget doesn't depend on the state, so you want
  /// to prevent it from rebuilding every time the state changes.
  const BlocSelector.child({
    Key? key,
    required this.selector,
    required BlocWidgetBuilderChild<T> builderChild,
    this.bloc,
    required this.child,
  })  : builderChild = builderChild,
        builder = null,
        super(key: key);

  /// If the pre-built subtree is passed as the [child] parameter, the
  /// [BlocConsumer] will pass it back to the `builderChild` function so that it
  /// can be incorporated into the build.
  final Widget? child;

  /// The [bloc] that the [BlocSelector] will interact with.
  /// If omitted, [BlocSelector] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  final B? bloc;

  /// The [builder] function which will be invoked
  /// when the selected state changes.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [BlocBuilder].
  final BlocWidgetBuilder<T>? builder;

  /// The [builderChild] function which will be invoked on each widget build.
  /// The [builderChild] takes the `BuildContext` and current `state` and
  /// `child` and must return a widget. The child should typically be part
  /// of the returned widget tree.
  /// This is analogous to the [builder] function in [StreamBuilder] but with
  /// a [child] parameter wich is built only the first time.
  final BlocWidgetBuilderChild<T>? builderChild;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current state.
  final BlocWidgetSelector<S, T> selector;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();
}

class _BlocSelectorState<B extends StateStreamable<S>, S, T>
    extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = widget.selector(_bloc.state);
  }

  @override
  void didUpdateWidget(BlocSelector<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
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
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder?.call(context, _state) ??
          widget.builderChild!.call(context, _state, widget.child!),
    );
  }
}
