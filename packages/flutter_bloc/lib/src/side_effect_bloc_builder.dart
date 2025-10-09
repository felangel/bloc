import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A callback type for handling side effects with the current state.
///
/// Takes the current [state] and emitted [effect] as parameters.
typedef EffectHandler<T, S> = void Function(S state, T effect);

/// A Flutter widget that builds UI based on the state of a [SideEffectBloc]
/// and handles its side effects.
///
/// This widget listens to the [effectsStream] of the provided [SideEffectBloc]
/// and triggers the [effectHandler] when a side effect is emitted, while using
/// [BlocBuilder] to rebuild the UI based on state changes.
///
/// Type parameters:
/// - `B`: The type of [SideEffectBloc] handling events, state, and effects.
/// - `S`: The type of state managed by the BLoC.
/// - `E`: The type of side effects emitted by the BLoC.
class SideEffectBlocBuilder<B extends SideEffectBloc<dynamic, S, E>, S, E>
    extends StatefulWidget {
  /// Creates a [SideEffectBlocBuilder] widget.
  ///
  /// - [bloc]: The [SideEffectBloc] instance to listen to. If null, it is read
  ///   from the context using [BlocProvider].
  /// - [builder]: A function that builds the UI based on the current state.
  /// - [effectHandler]: A callback to handle side effects with the current state.
  /// - [buildWhen]: An optional condition to control when the widget rebuilds
  ///   based on state changes.
  const SideEffectBlocBuilder({
    required this.builder,
    required this.effectHandler,
    this.bloc,
    this.buildWhen,
    Key? key,
  }) : super(key: key);

  /// The [SideEffectBloc] instance to listen to for state and effects.
  final B? bloc;

  /// A function that builds the UI based on the current state.
  final BlocWidgetBuilder<S> builder;

  /// An optional condition to determine whether to rebuild on state changes.
  final BlocBuilderCondition<S>? buildWhen;

  /// A callback to handle side effects with the current state.
  final EffectHandler<S, E> effectHandler;

  @override
  State<SideEffectBlocBuilder<B, S, E>> createState() =>
      _SideEffectBlocBuilderState<B, S, E>();
}

/// The state class for [SideEffectBlocBuilder].
///
/// Manages the subscription to the [effectsStream] and ensures proper cleanup.
class _SideEffectBlocBuilderState<B extends SideEffectBloc<dynamic, S, E>, S, E>
    extends State<SideEffectBlocBuilder<B, S, E>> {
  /// The [SideEffectBloc] instance used for state and effect handling.
  late final B effectBloc;

  /// The subscription to the [effectsStream] for handling side effects.
  late final StreamSubscription<E> _subscription;

  @override
  void initState() {
    super.initState();
    // Initialize the BLoC, either from widget.bloc or context.
    effectBloc = widget.bloc ?? context.read<B>();

    // Subscribe to the effects stream and invoke effectHandler on each effect.
    _subscription = effectBloc.effectsStream.listen(
          (effect) {
        try {
          widget.effectHandler(effect, effectBloc.state);
        } catch (e) {
          // Ignored exception to prevent crashes from effect handling errors.
        }
      },
      onError: (err) => debugPrint('Error in effect stream: $err'),
    );
  }

  @override
  void dispose() {
    // Cancel the effect stream subscription to prevent memory leaks.
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to rebuild the UI based on state changes.
    return BlocBuilder<B, S>(
      bloc: effectBloc,
      buildWhen: widget.buildWhen,
      builder: widget.builder,
    );
  }
}