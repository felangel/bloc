import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for the `create` function which
/// is responsible to create the mutable state `T`
typedef BlocWidgetCreate<S, T> = T Function(S state);

/// Signature for the `muteOrCopy` function which
/// is responsible to mute or copy the mutable state `T`
typedef BlocWidgetMuteOrCopy<S, T> = T? Function(T prev, S currentState);

/// Signature for the `muteWhen` function which
/// is responsible to mute `T` in a more granular way.
typedef BlocWidgetMuteWhen<S> = bool Function(S previous, S current);

/// {@template bloc_mute_selector}
/// Similar to a [BlocSelector], except it allows for mutating the state [T].
///
/// When a [BlocMuteSelector] is created, the [create] method is called,
/// and on every update (use [muteWhen] for more granular state
/// change selection), the [muteOrCopy] method is invoked.
///
/// If [muteOrCopy] returns a non-null value, the value will be copied
/// (similar to a [BlocSelector] or create). If it returns null,
/// a mutation has been performed, and the [builder] will be invoked again.
///
/// ```dart
/// BlocMuteSelector<BlocA, BlocAState, MutableSelectedState>(
///   create: (state) {
///     // create the mutable state
///   }
///   muteOrCopy: (prev, state) {
///     // mute the previous `MutableSelectedState` using current `BlocAState`
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class BlocMuteSelector<B extends BlocBase<S>, S, T> extends StatefulWidget {
  /// {@macro bloc_mute_selector}
  const BlocMuteSelector({
    required this.muteOrCopy,
    required this.create,
    required this.builder,
    this.muteWhen,
    this.bloc,
    Key? key,
  }) : super(key: key);

  /// The [bloc] that the [BlocMuteSelector] will interact with.
  /// If omitted, [BlocMuteSelector] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  final B? bloc;

  /// The [builder] function which will be invoked when a mutation
  /// has been performed.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [BlocBuilder].
  final Widget Function(BuildContext context, T state) builder;

  /// The [create] function which will be invoked on the first [bloc] render.
  final BlocWidgetCreate<S, T> create;

  /// The [muteOrCopy] function which will be invoked on state updates.
  ///
  /// Mute `prev` using `currentState` or create a new state [T].
  /// If [muteOrCopy] returns a non-null value, the value will be copied
  /// (similar to a [BlocSelector] or [create]). If it returns null,
  /// a mutation has been performed, and the [builder] will be invoked again.
  final BlocWidgetMuteOrCopy<S, T> muteOrCopy;

  /// Apply [muteOrCopy] only when [muteWhen] return true.
  final BlocWidgetMuteWhen<S>? muteWhen;

  @override
  State<BlocMuteSelector<B, S, T>> createState() =>
      _BlocMuteSelectorState<B, S, T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(ObjectFlagProperty<BlocWidgetBuilder<T>>.has('builder', builder))
      ..add(
        ObjectFlagProperty<BlocWidgetCreate<S, T>>.has(
          'create',
          create,
        ),
      )
      ..add(
        ObjectFlagProperty<BlocWidgetMuteOrCopy<S, T>>.has(
          'muteOrCopy',
          muteOrCopy,
        ),
      )
      ..add(
        ObjectFlagProperty<BlocWidgetMuteWhen<S>>.has(
          'muteWhen',
          muteWhen,
        ),
      );
  }
}

class _BlocMuteSelectorState<B extends BlocBase<S>, S, T>
    extends State<BlocMuteSelector<B, S, T>> {
  late T _mutablePartialState;
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _mutablePartialState = widget.create(_bloc.state);
  }

  @override
  void didUpdateWidget(BlocMuteSelector<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _mutablePartialState = widget.create(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _mutablePartialState = widget.create(_bloc.state);
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
        final copied = widget.muteOrCopy(_mutablePartialState, state);
        if (copied == null) {
          // mutated, always re-render
          setState(() {});
          return;
        }
        if (copied != _mutablePartialState) {
          setState(() => _mutablePartialState = copied);
        }
      },
      listenWhen: widget.muteWhen,
      child: widget.builder(context, _mutablePartialState),
    );
  }
}
