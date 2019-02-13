import 'package:bloc/bloc.dart';

/// Handles events from all [Bloc]s
/// which are delegated by the [BlocSupervisor].
class BlocDelegate {
  /// Called whenever a transition occurs with the given [Transition] in any [Bloc].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s state has been updated.
  /// A great spot to add universal logging/analytics.
  void onTransition(Transition transition) => null;

  /// Called whenever an [Exception] is thrown within `mapEventToState` for any [Bloc].
  /// The stacktrace argument may be `null` if the state stream received an error without a [StackTrace].
  /// A great spot to add universal error handling.
  void onError(Object error, StackTrace stacktrace) => null;
}
