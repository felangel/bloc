import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// Handles events from all [Bloc]s
/// which are delegated by the [BlocSupervisor].
class BlocDelegate {
  /// Called whenever a transition occurs with the given [Transition] in any [Bloc].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s state has been updated.
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onTransition(Transition transition) => null;

  /// Called whenever an event is emitted using [EventProviderBloc].
  /// Events are emitted when `_mapEventToState` calls `emitEvent()` with an [Event].
  /// `onEmitEvent` is called before any listener receves the event.
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onEmitEvent(dynamic event) => null;

  /// Called whenever an [Exception] is thrown within `mapEventToState` for any [Bloc].
  /// The stacktrace argument may be `null` if the state stream received an error without a [StackTrace].
  /// A great spot to add universal error handling.
  @mustCallSuper
  void onError(Object error, StackTrace stacktrace) => null;
}
