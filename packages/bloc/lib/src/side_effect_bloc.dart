import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// A BLoC base class that extends `Bloc` to support emitting side effects
/// alongside state updates, enabling decoupled handling of transient events
/// (e.g., navigation, toasts) in a Flutter application.
///
/// This class introduces a separate stream for side effects, allowing the UI
/// to react to non-state changes without bloating the state model.
///
/// Type parameters:
/// - `Event`: The type of events the BLoC handles.
/// - `State`: The type of state the BLoC manages.
/// - `Effect`: The type of side effects emitted by the BLoC.
abstract class SideEffectBloc<Event, State, Effect> extends Bloc<Event, State> {
  /// Creates a `SideEffectBloc` with the specified [initialState].
  SideEffectBloc(State initialState) : super(initialState) {
    _effectController = StreamController<Effect>.broadcast();
  }

  /// The internal controller managing the stream of side effects.
  late final StreamController<Effect> _effectController;

  /// Stream of side effects emitted by the BLoC.
  ///
  /// Widgets can listen to this stream to react to side effects, such as
  /// showing a snackbar or navigating to a new route.
  Stream<Effect> get effectsStream => _effectController.stream;

  /// Emits a new [effect] to the [effectsStream].
  ///
  /// This method should be called by subclasses to trigger side effects.
  /// Throws a [StateError] if called after the BLoC is closed.
  @visibleForTesting
  @protected
  void emitEffect(Effect effect) {
    if (isClosed) throw StateError('Cannot add effects after close');
    _effectController.add(effect);
    onEffect(effect);
  }

  /// Called whenever an [effect] is emitted.
  ///
  /// Subclasses can override this method to perform additional logic
  /// when a side effect is emitted. By default, it does nothing.
  @protected
  void onEffect(Effect effect) {}

  /// Closes the BLoC and its resources.
  ///
  /// Ensures the [effectsStream] is properly closed before closing the BLoC.
  /// Must be called by subclasses overriding this method.
  @override
  @mustCallSuper
  Future<void> close() async {
    await _effectController.close();
    await super.close();
  }
}