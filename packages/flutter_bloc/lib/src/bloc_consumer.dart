import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [BlocConsumer] is analogous to a nested `BlocListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [BlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [bloc].
///
/// [BlocConsumer] takes a required `BlocWidgetBuilder`
/// and `BlocWidgetListener` and an optional [bloc],
/// `BlocBuilderCondition`, and `BlocListenerCondition`.
///
/// If the [bloc] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [bloc] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
/// the [BlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
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
class BlocConsumer<B extends StateStreamable<S>, S> extends StatefulWidget {
  /// {@macro bloc_consumer}
  const BlocConsumer({
    Key? key,
    required BlocWidgetBuilder<S> builder,
    required this.listener,
    this.bloc,
    this.buildWhen,
    this.listenWhen,
  })  : builder = builder,
        builderChild = null,
        child = null,
        super(key: key);

  /// Similar to [BlocConsumer] but gives a [child] parameter
  /// as a pre-built subtree and pass it back to the `builderChild` function.
  /// The [child] is built only the first time. This is good for whene
  /// a part of your widget doesn't depend on the state, so you want
  /// to prevent it from rebuilding every time the state changes.
  const BlocConsumer.child({
    Key? key,
    required BlocWidgetBuilderChild<S> builderChild,
    required this.listener,
    this.bloc,
    this.buildWhen,
    this.listenWhen,
    required this.child,
  })  : builderChild = builderChild,
        builder = null,
        super(key: key);

  /// If the pre-built subtree is passed as the [child] parameter, the
  /// [BlocConsumer] will pass it back to the `builderChild` function so that it
  /// can be incorporated into the build.
  final Widget? child;

  /// The [bloc] that the [BlocConsumer] will interact with.
  /// If omitted, [BlocConsumer] will automatically perform a lookup using
  /// `BlocProvider` and the current `BuildContext`.
  final B? bloc;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S>? builder;

  /// The [builderChild] function which will be invoked on each widget build.
  /// The [builderChild] takes the `BuildContext` and current `state` and
  /// `child` and must return a widget. The child should typically be part
  /// of the returned widget tree.
  /// This is analogous to the [builder] function in [StreamBuilder] but with
  /// a [child] parameter wich is built only the first time.
  final BlocWidgetBuilderChild<S>? builderChild;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BlocBuilderCondition<S>? buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [BlocConsumer] with the current `state`.
  final BlocListenerCondition<S>? listenWhen;

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();
}

class _BlocConsumerState<B extends StateStreamable<S>, S>
    extends State<BlocConsumer<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
  }

  @override
  void didUpdateWidget(BlocConsumer<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) _bloc = currentBloc;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) _bloc = bloc;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return widget.builder != null
        ? BlocBuilder<B, S>(
            bloc: _bloc,
            builder: widget.builder!,
            buildWhen: (previous, current) {
              if (widget.listenWhen?.call(previous, current) ?? true) {
                widget.listener(context, current);
              }
              return widget.buildWhen?.call(previous, current) ?? true;
            },
          )
        : BlocBuilder<B, S>.child(
            bloc: _bloc,
            child: widget.child!,
            builderChild: widget.builderChild!,
            buildWhen: (previous, current) {
              if (widget.listenWhen?.call(previous, current) ?? true) {
                widget.listener(context, current);
              }
              return widget.buildWhen?.call(previous, current) ?? true;
            },
          );
  }
}
